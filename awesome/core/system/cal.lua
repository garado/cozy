
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- For interfacing with Google agendaendar through gcalcli

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local core    = require("helpers.core")

local agenda = { }
local instance = nil
local cache_path = gfs.get_cache_dir() .. "cal"

local curmonth  = os.date("%m")
local curdate   = os.date("%d")

local addtypes = {
  TITLE = 1,
  LOCATION = 2,
  WHEN = 3,
  DURATION = 4,
}

---------------------------------------------------------------------

--- Checks if the cache is empty. If empty then gcalcli probably needs to be reauthenticated.
-- Sends a notification asking if it should open the gcalcli reauthentication window.
function agenda:check_cache_empty()
  -- First check if cache file exists (if not, then it creates it)
  if not gfs.file_readable(cache_path) then
    local cmd = "touch " .. cache_path
    awful.spawn.with_shell(cmd)
  end

  -- Then check empty
  local cmd = "cat " .. cache_path
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout ~= "" then
      self:emit_signal("cache::not_empty")
    else
      self:update_cache()
    end
  end)
end

--- Use gcalcli cmd to write the last 3 months and next 3 months of data to cache
function agenda:update_cache()
  local cmd = "gcalcli agenda '3 months ago' '3 months' --details location --tsv > " .. cache_path
  awful.spawn.easy_async_with_shell(cmd, function(_)
    self:emit_signal("cache::updated")
    self:emit_signal("cache::not_empty")
  end)
end

--- Fetch data from cache for a specific month and store in object.
-- @param year The year (yyyy)
-- @param month The month (mm)
function agenda:fetch_month(year, month)
  -- Default to this year, this month if no args provided
  year  = year or os.date("%Y")
  month = month or curmonth

  -- cat cache_path | grep 2022-07
  local date = year .. "-" .. string.format("%02d", month)
  local grep = "grep " .. date
  local cmd = "cat " .. cache_path .. " | "  .. grep

  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self._private.events[month] = {}
    local lines = core.split("\r\n", stdout)

    --- Grab tab-separated fields of each event
    -- In order, fields are: start day, start time, end day, end time, title
    for i = 1, #lines do
      local event = {}

      local fields = core.split('\t', lines[i])
      for j = 1, #fields do
        event[#event+1] = fields[j]
      end

      local day = tonumber(string.sub(event[1], -2)) or 0
      if not self._private.events[month][day] then
        self._private.events[month][day] = {}
      end
      table.insert(self._private.events[month][day], event)
    end

    self:emit_signal("ready::month_events")
  end)
end

--- Fetch the next few upcoming events starting from a given date.
function agenda:fetch_upcoming()
  local cmd = gfs.get_configuration_dir() .. "utils/fetchupcoming " .. cache_path
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local upcoming = {}

    local lines = core.split("\r\n", stdout)
    for i = 1, #lines do
      local event = {}
      local fields = core.split('\t', lines[i])
      for j = 1, #fields do
        event[#event+1] = fields[j]
      end
      upcoming[#upcoming+1] = event
    end

    self._private.upcoming = upcoming
    self:emit_signal("ready::upcoming")
  end)
end

--- Turn date from 2022-12-11 to Sun 11 Dec
-- @param datestr A date in the format 2022-12-11
function agenda:format_date(datestr)
  local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
  local xyear, xmon, xday = datestr:match(pattern)
  local ts = os.time({ year = xyear, month = xmon, day = xday })
  return os.date("%a %b %d", ts)
end

-- █▀▀ █▀█ █▀▄▀█ █▀▄▀█ ▄▀█ █▄░█ █▀▄ █▀ 
-- █▄▄ █▄█ █░▀░█ █░▀░█ █▀█ █░▀█ █▄▀ ▄█ 

-- Editing events in gcalcli is done interactively with stdin,
-- so we have to jump through a few odd hoops to execute the edit command through dashboard
-- Example: to edit the title of an event, the command would look like
-- ( echo "t" & echo "newtitle" & echo "s"  & cat ) | gcalcli edit Eventtitle 2023-01-06
local function genpipecmd(arr)
  local function _echo(input)
    return ' echo \"' .. input .. '\" '
  end

  if #arr == 0 then return end

  local pipecmd = '( '
  for i = 1, #arr do
    pipecmd = pipecmd .. _echo(arr[i]) .. '&'
  end

  return pipecmd .. ' cat )'
end

--- Build gcalcli command based on input and input type, then execute.
function agenda:execute_request(_, type, input)
  local title = self.cur_title or ""
  local date  = self.cur_date or ""
  print('CORE: caught input::request:' .. type .. ' for event ' .. title .. ' on ' .. date)

  local cmd = ""

  if type == "add" then
    -- Split on semicolons
    local fields = core.split(';', input)
    local title = " --title " .. fields[addtypes.TITLE]
    local loc   = " --where " .. fields[addtypes.LOCATION]
    local dur   = " --duration " .. fields[addtypes.DURATION]
    local when  = " --when " .. fields[addtypes.WHEN]
    cmd = "gcalcli add" .. title .. loc .. dur .. when .. " --noprompt"
  end

  if type == "delete" then
    cmd = "echo 'y' | gcalcli delete '" .. title .. "' " .. date
  end

  if type == "refresh" then
    self:update_cache()
    return
  end

  local gcalcli_edit_cmd = "gcalcli edit '" .. title .. "' " .. date

  if type == "mod_title" then
    cmd = genpipecmd({ 't', input, 's', 'q'}) .. ' | ' .. gcalcli_edit_cmd
  end

  if type == "mod_loc" then
    cmd = genpipecmd({ 'l', input, 's', 'q'}) .. ' | ' .. gcalcli_edit_cmd
  end

  if type == "mod_when" then
    cmd = genpipecmd({ 'w', input, 's', 'q'}) .. ' | ' .. gcalcli_edit_cmd
  end

  if type == "mod_dur" then
    cmd = genpipecmd({ 'g', input, 's', 'q'}) .. ' | ' .. gcalcli_edit_cmd
  end

  print('CORE: ' .. cmd)
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    print('STDOUT:\n' .. stdout)
    print('STDERR:\n' .. stderr)
  end)
end

function agenda:create_event()
end

function agenda:edit_event()
end

function agenda:delete_event()
end

---------------------------------------------------------------------

function agenda:get_events() return self._private.events end
function agenda:get_upcoming_events() return self._private.upcoming end

function agenda:get_start_date(entry)  return entry[1] end
function agenda:get_start_time(entry)  return entry[2] end
function agenda:get_end_date(entry)    return entry[3] end
function agenda:get_end_time(entry)    return entry[4] end
function agenda:get_title(entry)       return entry[5] end

function agenda:get_location(entry)
  return #entry > 5 and entry[6] or ""
end

function agenda:get_num_events(month, date)
  if not self._private.events[month] then return 0 end
  if not self._private.events[month][date] then return 0 end

  return #self._private.events[month][date]
end

---------------------------------------------------------------------

function agenda:new()
  self._private.events = {}
  self:check_cache_empty()

  self:connect_signal("cache::not_empty", function()
    self:fetch_month()
    self:fetch_upcoming()
  end)

  --- BUG: issues when directly setting execute_request as callback
  self:connect_signal("input::complete", function(_, type, input)
    self:execute_request(_, type, input)
  end)
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, agenda, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
