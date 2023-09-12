-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Fetches data from gcalcli and defines api for accessing data.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local strutil = require("utils.string")
local calconf = require("cozyconf").calendar
local dash    = require("backend.cozy.dash")
local os      = os

local calendar = {}
local instance = nil

local CACHE_PATH = gfs.get_cache_dir() .. "calendar"
local SCRIPTS_PATH = gfs.get_configuration_dir() .. "utils/scripts/"
local SECONDS_IN_DAY = 24 * 60 * 60

---------------------------------------------------------------------

-- █▀▀ █▀▀ ▄▀█ █░░ █▀▀ █░░ █    ▄▀█ █▀█ █ 
-- █▄█ █▄▄ █▀█ █▄▄ █▄▄ █▄▄ █    █▀█ █▀▀ █ 

-- Functions that interact directly with gcalcli (plus some helpers)

--- @function _abbreviate_to_duration
-- @method Converts a string like "3h 15m" to a duration in minutes
local function _abbreviation_to_duration(dur)
  local tokens = strutil.split(dur, " ")

  local factor = {
    { "mins",  1 },
    { "min",  1 },
    { "mn",   1 },
    { "m",    1 },
    { "hours", 60 },
    { "hour",  60 },
    { "hrs",   60 },
    { "hr",    60 },
    { "h",     60 },
    { "days", 24 * 60 },
    { "day",  24 * 60 },
    { "d",    24 * 60 },
  }

  local minutes = 0

  for i = 1, #tokens do
    for j = 1, #factor do
      if tokens[i]:find(factor[j][1]) then
        tokens[i] = tokens[i]:gsub(factor[j][1], "")
        minutes = minutes + (factor[j][2] * tonumber(tokens[i]))
        break
      end
    end
  end

  return minutes
end

--- @function get_ts_from_time
-- @brief Turn any variation of a time string (10:15, 9am, 9:13pm, 1700, etc.) into
--        an os.time timestamp.
-- @return os.time timestamp
local function get_ts_from_time(str)
  str = str:gsub("%s", "") -- strip whitespace
  str = str:lower()
  local len = str:wlen()

  if len == 4 and tonumber(str) then
    -- military time
    return strutil.dt_convert(str, "%H%M")
  elseif (len == 3 or len == 4) and (str:find("am") or str:find("pm")) and not str:find(":") then
    -- 9am/10am or 9pm/10pm
    -- %H requires 2-char hour
    if not tonumber(str:sub(2,1)) then str = "0"..str end
    return strutil.dt_convert(str, "%H%p")
  elseif (len == 4 or len == 5) and str:find(":") and not (str:find("am") or str:find("pm")) then
    -- %H:%M
    if not tonumber(str:sub(2,2)) then str = "0"..str end
    return strutil.dt_convert(str, "%H:%M")
  elseif (len == 6 or len == 7) and str:find(":") then
    -- %H:%M%p
    if not tonumber(str:sub(2,1)) then str = "0"..str end
    return strutil.dt_convert(str, "%H:%M%p")
  else
    print("Unknown time format: "..str)
  end
end

--- @function _timespan_to_duration
-- @brief gcalcli doesn't accept specifying event end time - only duration.
--        so this is a function to calculate duration based on start and end times
local function _timespan_to_duration(stime, etime)
  local s_ts = get_ts_from_time(stime)
  local e_ts = get_ts_from_time(etime)
  local ret = (e_ts - s_ts) / 60

  -- If it ends up being negative it's usually because there's some wonkiness
  -- with timestrings that include "am" or "pm"
  if ret <= 0 then ret = ret + (12 * 60) end

  return ret
end

--- @function convert_duration
-- @brief Convert user input to a duration in minutes, because gcalcli only accepts
--        duration in minutes for some reason.
local function convert_duration(stime, arg2)
  arg2 = string.lower(arg2)

  -- Two cases: the user inputs an endtime or the user inputs a duration
  -- A numeric input is treated as an hour (e.g. '17' == '5pm')
  if arg2:find(":") or arg2:find("am") or arg2:find("pm") or tonumber(arg2) then
    return _timespan_to_duration(stime, arg2)
  else
    return _abbreviation_to_duration(arg2)
  end
end

--- @method add_event
-- @brief Add a new calendar event.
function calendar:add_event(args)
  if args.title == "" or args.start == "" or args.duration == "" then
    return
  end

  local dur = convert_duration(args.start, args.duration)

  strutil.print_arr(args)

  local title = "--title \"" .. args.title .. "\""
  local place = (args.place ~= "" and " --where \""..args.place .. "\"") or ""
  local start = " --when \"" .. args.date .. " " .. args.start .. "\""
  local duration = " --duration \"" .. dur .. "\""
  local cmd = "gcalcli add "..title..place..start..duration.." --noprompt"

  dash:emit_signal("snackbar::show", "Cozy calendar", "Event added. Updating cache...")
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    if stderr ~= "" or string.find(stdout, "error") then
      dash:emit_signal("snackbar::show", "Cozy calendar", "Failed to add event - please try again.")
    else
      self:update_cache()
    end
  end)
end

--- @function gen_pipe_cmd
-- @brief Editing/deleting events in gcalcli is done interactively with stdin,
--        so we have to jump through a few odd hoops to execute the
--        the edit/delete commands through the dashboard.
--        Example: to edit the title of an event, the command would look like:
--        ( echo "t" & echo "New title" & echo "s" & cat ) | gcalcli edit 'Title of event to edit'
-- @param arr Array of inputs to pipe to gcalcli.
--        In the example above, arr == { "t", "newtitle", "s" }
local function gen_pipe_cmd(arr)
  if #arr == 0 then return end

  local function _echo(input)
    return ' echo \"' .. input .. '\" '
  end

  local pipecmd = '( '
  for i = 1, #arr do
    pipecmd = pipecmd .. _echo(arr[i]) .. '&'
  end

  return pipecmd .. ' cat )'
end

--- @method modify_event
-- @brief
function calendar:modify_event(args)
  local event = self.active_element.event
  local cmd = "gcalcli edit \""..event.title.."\" '"..event.s_date.." "..event.s_time.."'"

  args.duration = convert_duration(args.start, args.duration)

  strutil.print_arr(args)

  args.when = args.date .. " " .. args.start

  local map = {
    ["title"]    = "t",
    ["place"]    = "l",
    ["when"]     = "w",
    ["duration"] = "g",
  }

  for type, value in pairs(args) do
    if map[type] and value ~= "" then
      cmd = gen_pipe_cmd({ map[type], value }) .. ' | ' .. cmd
    end
  end

  cmd = gen_pipe_cmd({'s', 'q'}) .. ' | ' .. cmd

  print(cmd)

  dash:emit_signal("snackbar::show", "Cozy calendar", "Event modified. Updating cache...")
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    print(stdout)
    print(stderr)
    self:update_cache()
  end)
end

--- @method delete
-- @brief Delete an event. This cannot be undone.
function calendar:delete(event)
  local cmd = "gcalcli delete '"..event.title.."' '"..event.s_date.." "..event.s_time .. "'"
  cmd = gen_pipe_cmd({'y', 'q'}) .. " | " .. cmd
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    dash:emit_signal("snackbar::show", "Cozy calendar", "Event deleted. Updating cache...")
    self:update_cache()
  end)
end

--- @method check_cache_empty
function calendar:check_cache_empty()
  -- Check existence
  if not gfs.file_readable(CACHE_PATH) then
    print('Cache does not exist')
  end

  -- Then check empty
  local cmd = 'cat ' .. CACHE_PATH
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout ~= "" then
      self:emit_signal("cache::ready")
    else
      self:update_cache()
    end
  end)
end

--- @method update_cache
-- @brief Fetch last 5 months and next 5 months of data from gcalcli
-- and store in cache file
function calendar:update_cache()
  local cmd = "gcalcli agenda '5 months ago' '5 months' --details location --details description --tsv > " .. CACHE_PATH
  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("cache::ready")
  end)
end

--- @function tsv_to_table
-- @brief Convert gcalcli output tsv into a table
local function tsv_to_table(stdout)
  local t = {}

  local lines = strutil.split(stdout, '\r\n')
  for i = 1, #lines do
    local event = {}
    local fields = strutil.split(lines[i], '\t', true)
    for j = 1, #fields do
      event[#event+1] = fields[j]
    end

    t[#t+1] = event
  end

  return t
end


-- █▀▄ ▄▀█ ▀█▀ ▄▀█    █░█ ▄▀█ █▄░█ █▀▄ █░░ █ █▄░█ █▀▀ 
-- █▄▀ █▀█ ░█░ █▀█    █▀█ █▀█ █░▀█ █▄▀ █▄▄ █ █░▀█ █▄█ 

-- All dates are in the format YYYY-MM-DD, or if you want to specify a time,
-- YYYY-MM-DD\t\tHH:MM. Either format works for all functions.

--- @method fetch_range
-- @param request_id    
-- @param range_start   Start of range
-- @param range_end     End of range
-- @brief Return table of events within a date range
function calendar:fetch_range(request_id, range_start, range_end)
  local signal = 'ready::range::' .. request_id
  local args = CACHE_PATH .. ' ' .. range_start .. ' ' .. range_end
  local cmd  = SCRIPTS_PATH .. 'fetchrange ' .. args
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal(signal, tsv_to_table(stdout))
  end)
end

--- @method fetch_anchored_range
-- @param request_id    
-- @param anchor_date   Starting date. Defaults to today if not specified.
-- @param days_before
-- @param days_after
-- @brief Given a starting date, returns table of events within a specified
--        number of days before and after the anchor date.
function calendar:fetch_anchored_range(request_id, anchor_date, days_before, days_after)
  anchor_date = anchor_date or os.date("%Y-%m-%d")

  -- To calculate the start/end dates, we need to convert to a timestamp first.
  local anchor_ts = strutil.datetime_to_ts(anchor_date)
  local start_ts  = anchor_ts - (days_before * SECONDS_IN_DAY)
  local end_ts    = anchor_ts + (days_after  * SECONDS_IN_DAY)
  local start_date = os.date("%Y-%m-%d", start_ts)
  local end_date   = os.date("%Y-%m-%d", end_ts)

  local signal = 'ready::anchored_range::' .. request_id
  local args = CACHE_PATH .. ' ' .. start_date .. ' ' .. end_date
  local cmd  = SCRIPTS_PATH .. 'fetchrange ' .. args
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self:emit_signal(signal, tsv_to_table(stdout))
  end)
end

--- @method fetch_upcoming
-- @param start_date  Default to today if not specified
-- @brief Fetch the next few upcoming events starting from a given date
function calendar:fetch_upcoming(request_id, start_date)
  start_date = start_date or os.date("%Y-%m-%d")

  local signal = 'ready::upcoming::' .. request_id
  local args = CACHE_PATH .. ' ' .. start_date .. ' ' .. 22
  local cmd = SCRIPTS_PATH .. 'fetchupcoming ' .. args
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    self:emit_signal(signal, tsv_to_table(stdout))
  end)
end


-- █▀▄▀█ █ █▀ █▀▀ 
-- █░▀░█ █ ▄█ █▄▄ 

--- @method get_weekview_start_ts
-- @brief The weekview tab in the dashboard calendar displays weekly schedule, by default
-- from Sunday - Saturday (start/end days specified within cozyconf). To get events for that
-- we call fetch_range on the starting Sunday and ending Saturday. This function returns the
-- os.time timestamp for the starting Sunday of the current week.
function calendar:get_weekview_start_ts()
  local now = os.time()
  local weekday_today = os.date("%w")
  return now - (weekday_today * SECONDS_IN_DAY)
end

function calendar:increment_hour()
  if self.end_hour == 24 then return end
  self.start_hour = self.start_hour + 1
  self.end_hour = self.end_hour + 1
  self:emit_signal("hours::adjust")
end

function calendar:decrement_hour()
  if self.start_hour == 0 then return end
  self.start_hour = self.start_hour - 1
  self.end_hour = self.end_hour - 1
  self:emit_signal("hours::adjust")
end

function calendar:jump_start_hour()
  self.start_hour = 0
  self.end_hour = 13
  self:emit_signal("hours::adjust")
end

function calendar:jump_middle_hour()
  self.start_hour = calconf.start_hour
  self.end_hour = calconf.end_hour
  self:emit_signal("hours::adjust")
end

function calendar:jump_end_hour()
  self.start_hour = 11
  self.end_hour = 24
  self:emit_signal("hours::adjust")
end

---------------------------------------------------------------------

function calendar:new()
  self.init = false

  -- When gcalcli dumps to tsv, this is the order of an event's fields.
  self.START_DATE = 1
  self.START_TIME = 2
  self.END_DATE   = 3
  self.END_TIME   = 4
  self.TITLE      = 5
  self.LOCATION   = 6
  self.DESCRIPTION = 7

  self:connect_signal("refresh", function()
    dash:emit_signal("snackbar::show", "Cozy calendar", "Refreshing cache...")
  end)

  -- Variables shared across UI elements
  self.weekview_cur_offset = 0
  self.start_hour = calconf.start_hour
  self.end_hour   = calconf.end_hour
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, calendar, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
