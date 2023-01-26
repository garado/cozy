
-- █ █▄░█ ▀█▀ █▀▀ █▀█ █▀▀ ▄▀█ █▀▀ █ █▄░█ █▀▀ 
-- █ █░▀█ ░█░ ██▄ █▀▄ █▀░ █▀█ █▄▄ █ █░▀█ █▄█ 

-- These functions talk to Taskwarrior directly

local gtable = require("gears.table")
local awful  = require("awful")
local core   = require("helpers.core")
local json   = require("modules.json")
local time   = require("core.system.time")
local task   = {}

local EMPTY_JSON = "[\n]\n"

--- Parse all tags
function task:parse_tags()
  local cmd = "task tag | head -n -2 | tail -n +4 | cut -f1 -d' ' "
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    if string.match(stderr, 'No tags') then return end
    local tags = core.split('\r\n', stdout)
    self.tag_names = tags
    self:emit_signal("ready::tag_names")
  end)
end

--- Parse all pending tasks for a given tag and then sort them by project
-- (As far as I'm aware this is the only way to initially obtain the list of projects for a tag) 
function task:parse_tasks_for_tag(tag)
  local cmd = "task context none; task +'"..tag.. "' '(status:pending or status:waiting)' export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == EMPTY_JSON or stdout == "" then return end

    if not self.tags[tag] then self:add_new_tag(tag) end

    local json_arr = json.decode(stdout)

    -- Iterate through all pending tasks for tag and separate by project
    for i, v in ipairs(json_arr) do
      local pname = json_arr[i]["project"] or "Unsorted"
      if not self.tags[tag].projects[pname] then
        self:add_new_project(tag, pname)
      end
      table.insert(self.tags[tag].projects[pname].tasks, v)
    end

    self:sort_projects(tag)

    for i = 1, #self.tags[tag].project_names do
      local pname = self.tags[tag].project_names[i]
      self:parse_total_tasks_for_project(tag, pname)
      self:sort_task_descriptions(tag, pname)
    end

    self:emit_signal("ready::project_names", tag)
    -- self:emit_signal("ready::tasks", tag)
  end)
end

-- Used to update only one project (almost positively the focused project).
-- Called after the user modifies a task to reflect the user's changes.
function task:parse_tasks_for_project(tag, project)
  local cmd = "task +'"..tag.."' project:'"..project.."' '(status:pending or status:waiting)' export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == EMPTY_JSON or stdout == "" then return end
    self.tags[tag].projects[project].tasks = json.decode(stdout)
    self:sort_task_descriptions(tag, project)
    self:emit_signal("ready::project_tasks", tag, project)
  end)
end

--- Get number of all tasks for project - completed and pending
-- The other function only returns pending tasks.
-- This information is required by project list and header.
function task:parse_total_tasks_for_project(tag, project)
  local unset_context = "task context none ; "
  local filters = "task +'"..tag.."' project:'"..project.."' "
  local status = " '(status:pending or status:completed or status:waiting)' "
  local cmd = unset_context .. filters .. status .. "count"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = tonumber(stdout) or 0
    self.tags[tag].projects[project].total = total

    local ready = self.tags[tag].projects_ready + 1
    self.tags[tag].projects_ready = ready
    if ready >= #self.tags[tag].project_names then
      self:emit_signal("ready::project_information", tag)
    end
  end)
end

--- Execute command given input and input type.
-- @param type    Type of input. See keybinds table in keybinds_tasklist.lua for complete list.
-- @param input   User input from awful.prompt
function task:execute_command(type, input)
  local ftag  = self.focused_tag
  local fproj = self.focused_project
  local ftask = self.focused_task
  local id = ftask["id"]
  local cmd

  if type == "add" then
    cmd = "task add proj:'"..fproj.."' tag:'"..ftag.."' '"..input.."'"
  end

  if type == "annotate" then
    cmd = "task " .. id .. " annotate " .. input
  end

  -- currently not used bc my taskwarrior hook fails when executing task undo
  -- if type == "undo" then
  --   if input == "y" or input == "Y" then
  --     cmd = "echo 'y' | task undo"
  --   else return end
  -- end

  if type == "delete" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task delete " .. id
    else return end
  end

  if type == "done" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task done " .. id
    else return end
  end

  if type == "open" then
    if input == "y" or input == "Y" then
      cmd = "xdg-open '" .. self.focused_task["link"] .. "'"
    else return end
  end

  if type == "search" then
    local tasks = self.tags[ftag].projects[fproj].tasks
    for i = 1, #tasks do
      if tasks[i]["description"] == input then
        self:emit_signal("tasklist::switch_index", i)
        return
      end
    end
  end

  if type == "start" then
    if ftask["start"] then
      cmd = "task " .. id .. " stop"
      time:emit_signal("set_tracking_inactive")
    else
      cmd = "task " .. id .. " start"
      time:emit_signal("set_tracking_active")
    end
  end

  if type == "reload" then
    if input == "y" or input == "Y" then
      self:reset()
      self.restore_required = true
    end
    return
  end

  -- Modal modify requests
  if type == "mod_due" then
    if input == "none" then input = '' end
    cmd = "task "..id.." mod due:'"..input.."'"
  elseif type == "mod_proj" then
    cmd = "task "..id.." mod proj:'"..input.."'"
  elseif type == "mod_tag" then
    cmd = "task "..id.." mod tag:'"..input.."'"
  elseif type == "mod_name" then
    cmd = "task "..id.." mod desc:'"..input.."'"
  elseif type == "mod_wait" then
    if input == "none" then input = '' end
    cmd = "task "..id.." mod wait:'"..input.."'"
  elseif type == "mod_link" then
    if input == "none" then input = '' end
    cmd = "task "..id.." mod link:'"..input.."'"
  end

  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    self:selective_reload(type, input)
  end)
end

return function(_task)
  gtable.crush(_task, task, true)
end
