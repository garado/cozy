
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Interfacing with Timewarrior.

-- Information on the currently tracked task is in self.tracking{}
-- Fields: id end tags{} annotation start

local json = require("modules.json")
local awful   = require("awful")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local strutil = require("utils.string")

local timewarrior = {}
local instance = nil

--- @method fetch_stats_today
-- @brief Get information for total time tracked today.
--        This information is for the dashboard Timew widget's idle screen.
function timewarrior:fetch_stats_today()
  local cmd = "timew sum today | tail -n 2"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if string.find(stdout, "No filtered data") then
      self:emit_signal("stats::inactive::ready", "0h 0m")
    else
      -- Convert from HH:MM:SS or MM:SS to 3h 2m
      local num_colons = strutil.count(":", stdout)
      stdout = stdout:gsub("%s", "") -- strip whitespace
      stdout = stdout:gsub(":%d%d$", "") -- strip seconds
      if num_colons == 1 then
        stdout = stdout:gsub(":", "m ")
      else
        stdout = stdout:gsub(":", "h ")
        stdout = stdout .. "m"
      end
      self:emit_signal("stats::today::ready", stdout)
    end
  end)
end

--- @method determine_if_active
-- @brief Check for active Timewarrior session. If present, emit signal to widgets.
--        If not, do nothing.
function timewarrior:determine_if_active()
  local cmd = "timew"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if not string.find(stdout, "There is no active time tracking") then
      self:set_tracking_active()
    end
  end)
end

--- @method set_tracking_active
-- @brief Fetch info on currently active task and emit signal telling widgets
--        that tracking is active.
function timewarrior:set_tracking_active()
  local cmd = "timew export @1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.tracking = json.decode(stdout)[1]
    self:emit_signal("tracking::active")
  end)
end

--- @method set_tracking_inactive
-- @brief Stop current Timewarrior session and emit signals to widgets.
function timewarrior:set_tracking_inactive()
  local cmd = "timew stop"
  awful.spawn.easy_async_with_shell(cmd, function()
    self.tracking = {}
    self:emit_signal("tracking::inactive")
  end)
end

---------------------------------------------------------------------

function timewarrior:new()
  self.tracking = {}
  self:determine_if_active()

  awesome.connect_signal("timew::active", function()
    self:set_tracking_active()
  end)

  awesome.connect_signal("timew::inactive", function()
    self:set_tracking_inactive()
  end)
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, timewarrior, true)
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
