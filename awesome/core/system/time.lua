
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Timewarrior.

local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")

local time = { }
local instance = nil

---------------------------------------------------------------------

--- Return the time spent working on a particular project for a particular tag.
function time:get_time_per_project(tag, project)
  local _tag = tag .. ":" .. project
  local cmd = "timew sum :all " .. _tag .. " | tail -n 2 | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if not self._private.tags then self._private.tags = {} end
    if not self._private.tags[tag].projects then
      self._private.tags[tag].projects = {}
    end

    -- If first char is a space, then there was (probably?) a valid
    -- Timewarrior output
    local first_char = string.sub(stdout, 1, 1)
    local proj_time
    if first_char ~= " " and first_char ~= "\t" then
      proj_time = ""
    else
      proj_time = string.gsub(stdout, "[^0-9:]", "")
    end

    self._private.tags[tag]["projects"][project] = proj_time
    -- task_obj.current_proj_total_time = proj_time

    -- task_obj:emit_signal("tasks::stats_tag_finished", "total_proj")
    self:emit_signal("update::project_stats")
  end)
end


---------------------------------------------------------------------




---------------------------------------------------------------------

function time:new()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, time, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
