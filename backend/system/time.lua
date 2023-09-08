
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Interfacing with Timewarrior.

local awful   = require("awful")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local strutil = require("utils.string")

local timewarrior = {}
local instance = nil

--- @method fetch_current_stats
-- @brief Get information on current focus, if any.
function timewarrior:fetch_current_stats()
  self.tracking = {}

  local cmd = "timew"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout:match("There is no active time tracking") then
      self:emit_signal("tracking::inactive")
    else
      -- Sample output:
      -- Tracking Cozy Cozy:Dashboard
      --   Started 2023-08-28T11:30:46
      --   Current            13:14:59
      --   Total               1:44:13

      local lines = strutil.split(stdout, "\r\n")
      local tmp

      -- Focus title
      tmp = strutil.split(lines[1], "%s")
      self.tracking.title = tmp[3]

      -- Time this session
      tmp = strutil.split(lines[3], "%s")
      self.tracking.current = tmp[2]

      -- Time today
      tmp = strutil.split(lines[4], "%s")
      self.tracking.today = tmp[2]

      self:emit_signal("tracking::active")
    end
  end)
end

--- @method fetch_current_task
-- @brief Stored as the most recent annotation.
function timewarrior:fetch_current_task()
  local cmd = ""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
  end)
end

--- @method stop
-- @brief Stop current Timewarrior session.
function timewarrior:stop()
  local cmd = "timew stop"
  awful.spawn.easy_async_with_shell(cmd, function()
    self.tracking = {}
    self:emit_signal("tracking::inactive")
  end)
end

---------------------------------------------------------------------

function timewarrior:new()
  self.tracking = {}
  self:fetch_current_stats()

  awesome.connect_signal("timew::active", function() print('active!!!!') end)
  awesome.connect_signal("timew::inactive", function() print('inactive!!!!') end)
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, timewarrior, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
