
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Taskwarrior.

-- Signals used       Args      Emitted when
-- -------------      -------   ---------------
-- ready::tags        -         taglist has been parsed
-- ready::projects    tag       project information retrieved (all tasks + total all-time tasks)
-- ready::tasks       tag       tasks for a given tag have been parsed
-- selected::tag      tag       a new tag has been selected (enter'd) in task manager
-- selected::project  project   a new project has been selected (enter'd) in task manager

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local json    = require("modules.json")
local core    = require("helpers.core")
local gears   = require("gears")
local config  = require("config")

local task = { }
local instance = nil

---------------------------------------------------------------------

-- █▀▀ █░█ █▄░█    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- █▀░ █▄█ █░▀█    ▄█ ░█░ █▄█ █▀░ █▀░ 

--- Get all tags
function task:get_taglist()
  local cmd = "task tag | head -n -2 | tail -n +4 | cut -f1 -d' ' "
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self._private.tags = core.split('\r\n', stdout)
    self:emit_signal("ready::tags")
  end)
end

--- Get all pending tasks for a given tag and then sort them by project
-- (As far as I'm aware this is the only way to obtain the list of projects for a tag)
function task:get_tasks_for_tag(tag)
  local cmd = "task context none; task tag:"..tag.. " status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local empty_json = "[\n]\n"
    if stdout ~= empty_json and stdout ~= "" then
      local json_arr = json.decode(stdout)

      -- Separate tasks by project
      local projects = {}
      for i, v in ipairs(json_arr) do
        local proj = json_arr[i]["project"] or "No project"
        if not projects[proj] then
          projects[proj] = {}
          projects[proj].tasks = {}
          projects[proj].total = 0
          self:parse_total_tasks_for_proj(tag, proj)
        end
        table.insert(projects[proj].tasks, v)
      end

      self._private.tags[tag] = {}
      self._private.tags[tag].projects = projects
      self._private.tags[tag].projects_ready = 0
      self:emit_signal("ready::tasks", tag)
    end
  end)
end

--- Get total number of tasks for a project - pending or completed
function task:parse_total_tasks_for_proj(tag, proj)
  local unset_context = "task context none ; "
  local filters = "task tag:'"..tag.."' project:'"..proj.."' "
  local status = " '(status:pending or status:completed)' "
  local cmd = unset_context .. filters .. status .. "count"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = tonumber(stdout) or 0
    self._private.tags[tag].projects[proj].total = total
    self:increment_projects_ready(tag)
  end)
end

function task:increment_projects_ready(tag)
  self._private.tags[tag].projects_ready = self._private.tags[tag].projects_ready + 1
  local ready = self._private.tags[tag].projects_ready
  if ready == self:num_projects_in_tag(tag) then
    self:emit_signal("ready::projects", tag)
  end
end

--- Returns the number of projects in a tag.
function task:num_projects_in_tag(tag)
  local tbl = self._private.tags[tag].projects
  return gears.table.count_keys(tbl)
end

-- TODO
--- Verify that the default tag (set in config.lua) actually exists. 
function task:verify_default_tag()
end

---------------------------------------------------------------------

-- █▀▀ █▀▀ ▀█▀ ▀█▀ █▀▀ █▀█ █▀ ░░▄▀ █▀ █▀▀ ▀█▀ ▀█▀ █▀▀ █▀█ █▀ 
-- █▄█ ██▄ ░█░ ░█░ ██▄ █▀▄ ▄█ ▄▀░░ ▄█ ██▄ ░█░ ░█░ ██▄ █▀▄ ▄█ 

function task:get_tags()  return self._private.tags end

function task:get_projects(tag)
  return self._private.tags[tag].projects
end

function task:get_focused_tag()   return self._private.focused_tag  end
function task:get_focused_proj()  return self._private.focused_proj end

function task:set_focused_tag(tag)    self._private.focused_tag   = tag end
function task:set_focused_proj(proj)  self._private.focused_proj  = proj end

function task:get_total_tasks_for_proj(tag, proj)
  return self._private.tags[tag].projects[proj].total
end

function task:get_proj_completion_percentage(tag, proj)
  local pending = #self._private.tags[tag].projects[proj].tasks
  local total = self._private.tags[tag].projects[proj].total
  local completed = total - pending
  return math.floor((completed / total) * 100) or 0
end

---------------------------------------------------------------------

function task:new()
  self._private.tags = {}
  self._private.focused_tag   = config.tasks.default_tag
  self._private.focused_proj  = config.tasks.default_project
  self._private.focused_task  = nil
  self:get_taglist()
  self:get_tasks_for_tag('Cozy')
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, task, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
