
-- █ █▄░█ ▀█▀ █▀▀ █▀█ █▀▀ ▄▀█ █▀▀ █▀▀ 
-- █ █░▀█ ░█░ ██▄ █▀▄ █▀░ █▀█ █▄▄ ██▄ 

-- These functions talk to Taskwarrior directly.

-- Resources:
-- - https://taskwarrior.org/docs/commands/export/

-- Task fields: uuid urgency due status entry modified id description

local awful   = require("awful")
local strutil = require("utils.string")
local gtable  = require("gears.table")
local json    = require("modules.json")
local gfs     = require("gears.filesystem")

local task = {}

local JSON_EXPORT = ' export rc.json.array=on'
local SCRIPTS_PATH = gfs.get_configuration_dir() .. "utils/scripts/"

--- @method fetch_today
-- @brief Fetch tasks due today.
function task:fetch_today()
  local cmd = "task due:today" .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal("ready::due::today", json.decode(stdout))
  end)
end

--- @method fetch_upcoming
-- @brief Fetch upcoming tasks.
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
-- Look at script for more details
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
    self:emit_signal("ready::tags_and_projects")
  end)
end

--- @method fetch_tasks_for_project
-- @param tag
-- @param project
function task:fetch_pending_tasks_for_project(tag, project)
  -- self:dbprint('Fetching tasks for '..project..' in '..tag)

  local cmd = "task status:pending tag:'"..tag.."' project:'"..project.."' " .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tasks = json.decode(stdout)

    -- Sort first by due date, then by name
    table.sort(tasks, function(a, b)
      return a.description:lower() < b.description:lower()
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

--- @brief Build and execute command given input and input type.
-- Also send signals to update UI elements if necessary.
-- @param type  Type of input. See keybinds table in frontent/task/keybinds.lua for complete list.
-- @param input User input from awful.prompt
function task:execute_command(type, input)
  print('backend:task: execute_command for '..type)
  print('    input: '..(input or ""))
  print('    tag: '..self.active_tag..', p: '..self.active_project..', t: '..self.active_task.id)

  local tag = self.active_tag
  local project = self.active_project
  local tdata = self.active_task

  local cmd
  if type == "add" then
    cmd = "task add project:'"..project.."' tag:'"..tag.."' '"..input.."'"
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
  end

  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("ui::update", type, input)
  end)
end

function task:interface_signal_setup()
  self:connect_signal("input::complete", self.execute_command)
end

return function(_task)
  gtable.crush(_task, task)
end
