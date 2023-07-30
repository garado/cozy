
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- This contains functions that interface with Taskwarrior.

-- This also keeps track of the active (currently selected) tag/project/task
-- when navigating the task tab UI. The active elements are updated as
-- part of the keynav functions defined for the navitems.

local beautiful = require("beautiful")
local awful   = require("awful")
local strutil = require("utils.string")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local json    = require("modules.json")
local gfs     = require("gears.filesystem")

local task = {}
local instance = nil

local JSON_EXPORT = ' export rc.json.array=on'
local SCRIPTS_PATH = gfs.get_configuration_dir() .. "utils/scripts/"


-- █ █▄░█ ▀█▀ █▀▀ █▀█ █▀▀ ▄▀█ █▀▀ █▀▀ 
-- █ █░▀█ ░█░ ██▄ █▀▄ █▀░ █▀█ █▄▄ ██▄ 

--- @method fetch_today
-- @brief Fetch tasks due today.
function task:fetch_today()
  local cmd = "task due:today" .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal("ready::due::today", json.decode(stdout))
  end)
end

--- @method fetch_upcoming
function task:fetch_upcoming()
  local cmd = "task +DUE -DUETODAY" .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal("ready::due::upcoming", json.decode(stdout))
  end)
end

--- @method fetch_overdue
-- @brief Fetch overdue tasks.
function task:fetch_overdue()
  local cmd = "task +OVERDUE " .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal("ready::due::overdue", json.decode(stdout))
  end)
end

--- @method fetch_tags_and_projects
-- @brief Fetches Taskwarrior tags and projects all at once.
-- Look at script (in utils/scripts) for more details.
function task:fetch_tags_and_projects()
  local cmd = SCRIPTS_PATH .. 'taskwarrior-tags-projects'
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.data = {}
    local tag_groups = strutil.split(stdout, '=====')
    table.remove(tag_groups, #tag_groups)

    for i = 1, #tag_groups do
      local projects = strutil.split(tag_groups[i], "\r\n")
      local tag = table.remove(projects, 1)
      self.data[tag] = projects
    end

    self.data["next"] = nil

    self:emit_signal("ready::tags_and_projects")
  end)
end

--- @method fetch_tasks_for_project
-- @param tag
-- @param project
function task:fetch_pending_tasks_for_project(tag, project)
  local cmd = "task status:pending tag:'"..tag.."' project:'"..project.."' " .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tasks = json.decode(stdout)

    table.sort(tasks, function(a, b)
      -- If neither have due dates or they have the same due date,
      -- then sort alphabetically
      if (not a.due and not b.due) or (a.due == b.due) then
        return a.description < b.description
      end

      -- Nearest due date should come first
      if a.due and not b.due then
        return true
      elseif not a.due and b.due then
        return false
      else
        return a.due < b.due
      end
    end)

    self.data[tag][project] = tasks
    self:emit_signal("ready::tasks", tag, project, tasks)
  end)
end

--- @method fetch_project_stats
-- @brief Get the number of pending and completed tasks for a project
function task:fetch_project_stats(tag, project)
  local cmd = SCRIPTS_PATH .. 'task-project-stats ' .. tag .. ' ' .. project
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local arr = strutil.split(stdout)
    self:emit_signal("ready::project_stats", arr[1] or 0, arr[2] or 0)
  end)
end

--- @method fetch_task_data
-- @brief Export task data for 1 task.
function task:fetch_task_data(id)
  local cmd = "task "..id.." export"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal("ready::task_data", json.decode(stdout))
  end)
end

--- @method fetch_due_soon_count_tag
-- @brief Fetch the number of tasks that are due soon/overdue for a tag.
-- Used in the task tab sidebar.
function task:fetch_due_count_tag(tag)
  local cmd = "task tag:'"..tag.."' status:pending \\(+DUE or +OVERDUE\\) export | wc -l"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local signal = "ready::duecount::" .. tag
    -- Subtract 2 because when running `task export`, the first and last lines are just brackets
    self:emit_signal(signal, tonumber(stdout) - 2)
  end)
end

--- @method fetch_due_soon_count_tag_project
-- @brief Fetch the number of tasks that are due soon/overdue for a project in a given tag.
-- Used in the task tab sidebar.
function task:fetch_due_count_project(tag, project)
  local cmd = "task tag:'"..tag.."' project:'"..project.."' status:pending \\(+DUE or +OVERDUE\\) export | wc -l"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local signal = "ready::duecount::" .. tag .. '::' .. project
    -- Subtract 2 because when running `task export`, the first and last lines are just brackets
    self:emit_signal(signal, tonumber(stdout) - 2)
  end)
end

--- @brief Build and execute command given input and input type.
-- Also send signals to update UI elements if necessary.
-- @param type  Type of input. See keybinds table in frontend/task/keybinds.lua for complete list.
-- @param input User input from awful.prompt
function task:execute_command(type, input)
  -- print('Backend:task: execute_command for '..type)
  -- print('    input: '..(input or ""))
  -- print('    tag: '..self.active_tag..', p: '..self.active_project..', t: '..self.active_task.id)

  -- For brevity
  local tag = self.active_tag
  local project = self.active_project
  local tdata = self.active_task

  local cmd
  if type == "add" then
    cmd = "task add project:'"..project.."' tag:'"..tag.."' '"..input.."'"
  end

  if type == "annotation" then
    cmd = "task "..tdata.id.." annotate '"..input.."'"
  end

  if type == "delete" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task delete " .. tdata.id
    else return end
  end

  if type == "done" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task done " .. tdata.id
    else return end
  end

  -- Toggle start/stop
  if type == "start" then
    if tdata.start then
      cmd = "task "..tdata.id.." stop"
    else
      cmd = "task "..tdata.id.." start"
    end
  end

  -- Modify requests
  if type == "mod_due" then
    if input == "none" then input = '' end
    cmd = "task "..tdata.id.." mod due:'"..input.."'"
  elseif type == "mod_project" then
    cmd = "task "..tdata.id.." mod project:'"..input.."'"
  elseif type == "mod_tag" then
    cmd = "task "..tdata.id.." mod tag:'"..input.."'"
  elseif type == "mod_name" then
    cmd = "task "..tdata.id.." mod desc:'"..input.."'"
  elseif type == "mod_uda" then
    cmd = "task "..tdata.id.." mod "..input
  end

  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("refresh", type, input)
  end)
end

--- @method gen_twdeps_image
-- @brief Use twdeps to generate a graph representing connections between
-- interdependent tasks.
-- https://github.com/garado/twdeps
-- NOTE: Currently unused (deps visualization hasn't been implemented for task tab)
function task:gen_twdeps_img()
  local tag     = self.active_tag
  local project = self.active_project
  local taskid  = self.active_task.id

  local task_cmd = "task tag:'"..tag.."' project:'"..project.."' export "
  local twdeps_args = " --taskid="..taskid..
                      " --title='Task Dependencies'"..
                      " --fg="..beautiful.fg..
                      " --sbfg="..beautiful.neutral[300]..
                      " --bg="..beautiful.neutral[900]..
                      " --nodebg="..beautiful.neutral[800]..
                      " --selbg="..beautiful.primary[100]..
                      " --selfg="..beautiful.primary[700]..
                      " --selsbfg="..beautiful.primary[500]..
                      " --green="..beautiful.green[400]..
                      " --fontname='"..beautiful.font_name.."'"
  local twdeps_cmd = "twdeps " .. twdeps_args .. '> ' .. self.deps_img_path
  local cmd = task_cmd .. ' | ' .. twdeps_cmd
  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("ready::dependencies")
  end)
end

----------------------------------

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

function task:signal_setup()
  -- UI signals
  self:connect_signal("selected::tag", function(_, tag)
    self.active_project = self.data[tag][1]
    self:emit_signal("selected::project", tag, self.data[tag][1])
  end)

  self:connect_signal("selected::project", self.fetch_pending_tasks_for_project)

  self:connect_signal("refresh", function()
    -- Used to restore position in task tab after refresh
    self.restore = {
      tag     = self.active_tag,
      project = self.active_project,
      id      = self.active_task.id,
    }
    self:fetch_tags_and_projects()
  end)

  -- Interface signals
  self:connect_signal("input::complete", self.execute_command)
end

----------------------------------

function task:new()
  self:signal_setup()
  self:fetch_tags_and_projects()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, task, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
