
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Fetches data from gcalcli and defines api for accessing data.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local strutil = require("utils.string")
local calconf = require("cozyconf").calendar
local os      = os

local calendar = {}
local instance = nil

local CACHE_PATH = gfs.get_cache_dir() .. "calendar"
local SCRIPTS_PATH = gfs.get_configuration_dir() .. "utils/scripts/"
local SECONDS_IN_DAY = 24 * 60 * 60

---------------------------------------------------------------------

-- █▀▄ ▄▀█ ▀█▀ ▄▀█    █▀█ █▀▀ ▀█▀ █▀█ █ █▀▀ █░█ ▄▀█ █░░ 
-- █▄▀ █▀█ ░█░ █▀█    █▀▄ ██▄ ░█░ █▀▄ █ ██▄ ▀▄▀ █▀█ █▄▄ 

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
-- number of days before and after the anchor date.
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
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
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
  self.end_hour = calconf.end_hour)
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
