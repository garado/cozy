
-- █ █▄░█ ▀█▀ █▀▀ █▀█ █▀▀ ▄▀█ █▀▀ █▀▀ 
-- █ █░▀█ ░█░ ██▄ █▀▄ █▀░ █▀█ █▄▄ ██▄ 

-- These functions talk to Taskwarrior directly.

local awful   = require("awful")
local strutil = require("utils.string")
local gtable  = require("gears.table")

local task = {}

-- How Task data is organized:
--    [tag]
--        [project]
--            [tasks]
--    [tag]
--        [project]
--            [tasks]

--- @method fetch_tags
-- @brief Fetch all currently active Taskwarrior tags.
function task:fetch_tags()
  -- self:dbprint('Fetching tags')

  -- The head/tail/awk stuff is for trimming down the task command's
  -- output to isolate the tags; it's got a lot of extraneous lines.
  -- (Pipe 'task tags' to a file to see).
  local cmd = "task tags | tail -n +4 | head -n -2 | awk 'NF--'"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.data = {}
    local tags = strutil.split(stdout, '\r\n')
    for i = 1, #tags do
      self.data[tags[i]] = {}
    end
    self:emit_signal("ready::tags", tags)
  end)
end

--- @method fetch_projects_for_tag
-- @param tag   A Taskwarrior tag to fetch projects for
-- @brief Fetch all currently active projects for a specified tag.
function task:fetch_projects_for_tag(tag)
  local cmd = "task tag:"..tag.." projects | tail -n +4 | head -n -2 | awk 'NF--'"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- self:dbprint('Fetching projects for '..tag)
    self.data[tag] = {}
    local projects = strutil.split(stdout, '\r\n')
    for i = 1, #projects do
      self.data[tag][projects[i]] = {}
    end
    self:emit_signal("ready::projects", tag, projects)
  end)
end

--- @method fetch_tasks_for_project
-- @param tag
-- @param project
-- @brief
function task:fetch_tasks_for_project(tag, project)
  self:dbprint('Fetching tasks for '..project..' in '..tag)
end

return function(_task)
  gtable.crush(_task, task)
end
