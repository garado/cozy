
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- For interfacing with Google Calendar through gcalcli

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local core    = require("helpers.core")

local agenda = { }
local instance = nil
local cache_path = gfs.get_cache_dir() .. "cal"

local curmonth  = tonumber(os.date("%m"))
local curdate   = tonumber(os.date("%d"))

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

--- Use gcalcli cmd to write the last 5 months and next 5 months of data to cache
function agenda:update_cache()
  local cmd = "gcalcli agenda '5 months ago' '5 months' --details location --tsv > " .. cache_path
  awful.spawn.easy_async_with_shell(cmd, function(_)
    self:emit_signal("cache::updated")
    self:emit_signal("cache::not_empty")
  end)
end

--- TODO: Should sort by year as well
--- Fetch data from cache for a specific month and store in table.
-- @param year The year (yyyy)
-- @param month The month (mm)
function agenda:fetch_month(month, year)
  -- Default to this year, this month if no args provided
  year  = year or tonumber(os.date("%Y"))
  month = tonumber(month) or curmonth

  -- Command looks like: cat cache_path | grep 2022-07
  local date = year .. "-" .. string.format("%02d", month)
  local grep = "grep " .. date
  local cmd = "cat " .. cache_path .. " | "  .. grep

  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.events[month] = {}
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
      if not self.events[month][day] then
        self.events[month][day] = {}
      end
      table.insert(self.events[month][day], event)
    end

    self:emit_signal("ready::month_events", tonumber(month), tonumber(year))
  end)
end

--- Fetch the next few upcoming events starting from a given date.
function agenda:fetch_upcoming(date)
  date = date or os.date("%Y-%m-%d")
  local cmd = gfs.get_configuration_dir() .. "utils/fetchupcoming " .. cache_path .. " " .. date
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

--- For some reason some gcalcli add only take durations in minutes, so this is
-- converts more human-readable inputs like 2h 15m, 3d, 20m, etc into minutes.
-- @param dur A duration or string of space-separated durations in the form #H, #D, #M, etc.
local function convert_duration(dur)
  local thingies = core.split(' ', dur)

  local factor = {
    ["m"] = 1,
    ["h"] = 60,
    ["d"] = 24 * 60,
  }

  local minutes = 0
  for i = 1, #thingies do
    local type = string.sub(thingies[i], -1) -- isolate H, M, or D
    type = string.lower(type)

    local numstr = string.sub(thingies[i], 1, -2) -- isolate number
    local num = tonumber(numstr)

    minutes = minutes + (factor[type] * num)
  end

  return minutes
end

-- Editing events in gcalcli is done interactively with stdin, so we have
-- to jump through a few odd hoops to execute the edit command through dashboard
-- Example: to edit the title of an event, the command would look like:
-- ( echo "t" & echo "newtitle" & echo "s"  & cat ) | gcalcli edit Eventtitle 2023-01-06
-- @param arr Array of inputs to pipe to gcalcli. In the example above, arr == { "t", "newtitle", "s" }
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

--- Build command based on input and input type, then execute.
-- @param type The input type
-- @param input The user input
function agenda:execute_request(_, type, input)
  if type == "refresh" then
    self:update_cache()
    return
  end

  local cmd = ""

  -- Open link
  if type == "open" then
    cmd = "xdg-open '" .. self.cur_loc .. "'"
  end

  -- Add commands (gcalcli add requires multiple consecutive inputs)

  if type == "add_title" then
    self.add_title = input
    local signal = self.return_to_confirm and "add_confirm" or "add_when"
    self:emit_signal("input::request", signal)
    return
  end

  if type == "add_when" then
    self.add_when = input
    local signal = self.return_to_confirm and "add_confirm" or "add_dur"
    self:emit_signal("input::request", signal)
    return
  end

  if type == "add_dur" then
    self.add_dur_unconverted = input
    self.add_dur = convert_duration(input)
    local signal = self.return_to_confirm and "add_confirm" or "add_loc"
    self:emit_signal("input::request", signal)
    return
  end

  if type == "add_loc" then
    self.add_loc = input
    self:emit_signal("input::request", "add_confirm")
    return
  end

  if type == "add_confirm" and (input == "s" or input == "S") then
    self.return_to_confirm = false
    local titlecmd = (self.add_title and " --title '"    .. self.add_title .. "'") or ""
    local loccmd   = (self.add_loc   and " --where '"    .. self.add_loc   .. "'") or ""
    local durcmd   = (self.add_dur   and " --duration '" .. self.add_dur   .. "'") or ""
    local whencmd  = (self.add_when  and " --when '"     .. self.add_when  .. "'") or ""
    cmd = "gcalcli add " .. titlecmd .. loccmd .. durcmd .. whencmd .. " --noprompt"
  end

  if type == "add_confirm" and (input ~= "s" and input ~= "S") then
    self.return_to_confirm = true

    if input == "t" then
      self:emit_signal("input::request", "add_title")
    elseif input == "w" then
      self:emit_signal("input::request", "add_when")
    elseif input == "d" then
      self:emit_signal("input::request", "add_dur")
    elseif input == "l" then
      self:emit_signal("input::request", "add_loc")
    end

    return
  end

  local title = self.cur_title or ""
  local date  = self.cur_date or ""

  if type == "delete" then
    cmd = genpipecmd({ 'y', 'q' }) .. ' | ' .. " gcalcli delete '" .. title .. "' " .. date
  end

  -- Edit commands ------------

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

  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    print('CORE: ' .. cmd)
    print('STDOUT:\n' .. stdout)
    print('STDERR:\n' .. stderr)

    -- If command executed successfully, update UI to reflect changes
    if stderr == "" then
      self:update_cache()
    end
  end)
end

function agenda:selected_date(year, month, date)
end

---------------------------------------------------------------------

function agenda:get_events() return self.events end
function agenda:get_upcoming_events() return self._private.upcoming end

function agenda:get_num_events(month, date)
  if not self.events[month] then return 0 end
  if not self.events[month][date] then return 0 end
  return #self.events[month][date]
end

---------------------------------------------------------------------

function agenda:new()
  self.events = {}

  -- Enum for accessing fields within event table
  self.START_DATE = 1
  self.START_TIME = 2
  self.END_DATE   = 3
  self.END_TIME   = 4
  self.TITLE      = 5
  self.LOCATION   = 6

  self:check_cache_empty()

  self:connect_signal("cache::not_empty", function()
    self:fetch_month()
    self:fetch_upcoming()
  end)

  --- BUG: issues when directly setting execute_request as callback
  self:connect_signal("input::complete", function(_, type, input)
    self:execute_request(_, type, input)
  end)

  self:connect_signal("selected::date", function(_, date)
    self:selected_date(date)
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
