
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

--- @method fetch_tags_and_projects
-- @brief Fetches Taskwarrior tags and projects together using custom script
function task:fetch_tags_and_projects()
  local cmd = SCRIPTS_PATH .. 'taskwarrior-tags-projects'
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.data = {}
    local tag_groups = strutil.split(stdout, '-----')
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
  self:dbprint('Fetching tasks for '..project..' in '..tag)

  local cmd = "task status:pending tag:'"..tag.."' project:'"..project.."' " .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tasks = json.decode(stdout)
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

return function(_task)
  gtable.crush(_task, task)
end
