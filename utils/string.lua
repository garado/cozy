
-- █▀ ▀█▀ █▀█ █ █▄░█ █▀▀    █░█ ▀█▀ █ █░░ █▀
-- ▄█ ░█░ █▀▄ █ █░▀█ █▄█    █▄█ ░█░ █ █▄▄ ▄█

local string = string -- Lua library

local _string = {}

-- █▀▄▀█ ▄▀█ █▄░█ █ █▀█ █░█ █░░ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █░▀░█ █▀█ █░▀█ █ █▀▀ █▄█ █▄▄ █▀█ ░█░ █ █▄█ █░▀█

--- @function first_to_upper
-- @brief Capitalize the first letter of the string
function _string.first_to_upper(str)
  return (str:gsub("^%l", string.upper))
end

--- @function split
-- @brief Split text input on a given delimiter.
-- @param text  A string to delimit.
-- @param delim Delimiting character(s)
-- @param keepEmpty True if empty tokens should be kept (stored
--                  in return array as "")
-- @return A table containing the split tokens.
function _string.split(text, delim, keepEmpty)
  delim = delim or "%s" -- default all whitespace
  keepEmpty = keepEmpty or false

  local match
  if keepEmpty then
    text  = text .. delim
    match = "([^" .. delim .. "]*)" .. delim
  else
    match = "([^" .. delim .. "]+)"
  end

  local ret = {}
  for str in text:gmatch(match) do
    ret[#ret + 1] = str
  end
  return ret
end

--- @function hasprefix
-- @brief Check if string starts with another string
-- @param text    Text to search through
-- @param prefix  Text to look for
function _string.hasprefix(text, prefix)
  return string.sub(text, 1, string.len(prefix)) == prefix
end

--- @method count
-- @brief Count the number of occurrences of a pattern character in the string.
function _string.count(str, pattern)
  local _, count = str:gsub("%" .. pattern, "")
  return count
end

-- █▀▄ ▄▀█ ▀█▀ █▀▀    ▄▀█ █▄░█ █▀▄    ▀█▀ █ █▀▄▀█ █▀▀
-- █▄▀ █▀█ ░█░ ██▄    █▀█ █░▀█ █▄▀    ░█░ █ █░▀░█ ██▄

-- Define these here so they don't get created each time dt_convert is called.
-- NOTE: Tables need to be numerically indexed because the order matters a lot and
-- associative arrays are in a kind of random order when you iterate through them.

local DT_OPTIONS = {
  "%%d", -- Day [01-31]
  "%%H", -- Hour [00-23]
  "%%h", -- Hour [01-12]
  "%%M", -- Minute [00-59]
  "%%S", -- Second [00-59]
  "%%y", -- Two-digit year
  "%%m", -- Month [01-12]
  "%%p", -- "am" or "pm"
  "%%a", -- Weekday name (3 letters)
  "%%Y", -- Full year
}

local DT_MATCH_REPLACE = {
  "(%%d%%d)", -- Day [01-31]
  "(%%d%%d)", -- Hour [00-23]
  "(%%d%%d)", -- Hour [01-12]
  "(%%d%%d)", -- Minute [00-59]
  "(%%d%%d)", -- Second [00-59]
  "(%%d%%d)", -- Two-digit year
  "(%%d%%d)", -- Month [01-12]
  "(%%l%%l)", -- "am" or "pm"
  "(%%l%%l%%l)", -- Weekday name (3 letters)
  "(%%d%%d%%d%%d)", -- Full year
}

local DT_LETTERS = {
  ["Y"] = "year",
  ["d"] = "day",
  ["H"] = "hour",
  ["h"] = "hour",
  ["M"] = "min",
  ["m"] = "month",
}

_string.dt_format = {
  standard = "%Y-%m-%d",
  iso = "%Y%m%dt%H%M%Sz",
}

-- @brief Convert a datetime string to another format.
--        This function is meant to be a catch-all replacement for all of the datetime
--        conversion functions I've had to write because writing really specific conversion
--        functions got annoying.
-- @note  All subjects get converted to lowercase.
-- @param subject       The string to convert, i.e. "2023-03-02"
-- @param old_pattern   The pattern for the subject string, i.e. "%Y-%m-%d"
--                      If not specified, %Y-%m-%d is assumed.
-- @param new_pattern   The new pattern, i.e. "%A %M %d"
--                      If not specified, the function returns the raw timestamp.
function _string.dt_convert(subject, old_pattern, new_pattern)
  subject = subject:lower()
  old_pattern = old_pattern or "%Y-%m-%d"

  local debug = false

  if debug then print('=== DTC: CONVERTING '..subject..' WITH PATTERN '..old_pattern.." ===") end

  -- Record the order in which matches appear.
  -- This generates a table that for the example case %Y-%m-%d looks like { "Y", "m", "d" }
  local captures = _string.split(old_pattern, "%%")
  for i = 1, #captures do
    captures[i] = captures[i]:sub(1, 1)
  end

  if debug then _string.print_arr(captures) end

  -- This takes the subject string: 2023-04-02
  -- And the old_pattern information: %Y-%m-%d
  -- And turns old_pattern into this: (%d%d%d%d)-(%d%d)-(%d%d)
  for i = 1, #DT_OPTIONS do
    if old_pattern:find(DT_OPTIONS[i]) then
      old_pattern = string.gsub(old_pattern, DT_OPTIONS[i], DT_MATCH_REPLACE[i])
    end
  end

  if debug then print('Old pattern converted to '..old_pattern) end

  -- Get table of matches using old_pattern (%d%d%d%d)-(%d%d)-(%d%d)
  local match_values = { subject:match(old_pattern) }

  if debug then _string.print_arr(match_values) end

  -- Set up inputs to get os.time timestamp
  local timetable = {
    ["day"]   = 1,
    ["month"] = 1,
    ["year"]  = 1970,
  }

  for i = 1, #captures do
    if DT_LETTERS[captures[i]] then
      timetable[DT_LETTERS[captures[i]]] = match_values[i]
    end
  end

  if debug then _string.print_arr(timetable) end

  local ts = os.time(timetable)
  local tz_offset = require("cozyconf").timezone or 0
  ts = ts + (tz_offset * 60 * 60)

  if debug then print('Timestamp: '..ts) end

  return (new_pattern and os.date(new_pattern, ts)) or ts
end

-- Abbreviated function call for convenience.
_string.dtc = _string.dt_convert

--- @method ts_to_relative
-- @brief Convert an os.time timestamp to relative time
--        i.e. '1 day ago', '2 months ago'
-- @param ts  os.time timestamp for the date to convert
function _string.ts_to_relative(ts)
  local now = os.time()
  local diff = now - ts
  local overdue = diff > 0
  diff = math.abs(diff)

  local SECONDS_IN_HOUR = 60 * 60
  local SECONDS_IN_DAY = 24 * SECONDS_IN_HOUR

  local timestr, divisor

  if diff < SECONDS_IN_HOUR then
    timestr = "minute"
    divisor = 60
  elseif diff < SECONDS_IN_DAY then
    timestr = "hour"
    divisor = SECONDS_IN_HOUR
  else
    timestr = "day"
    divisor = SECONDS_IN_DAY
  end

  local res = math.floor(diff / divisor)
  local plural = res == 1 and "" or "s"
  local relative = res .. ' ' .. timestr .. plural

  if overdue then
    relative = relative .. ' ago'
  else
    relative = 'in ' .. relative
  end

  return relative, overdue
end

--- @method time_to_float
-- @brief Converts time in HH:MM to a float [0-24).
--        i.e. 23:15 -> 23.25
-- @param time  A time in format HH:MM 24-hour time
function _string.time_to_float(time)
  local fields = _string.split(time, ":")
  local h = tonumber(fields[1])
  local m = tonumber(fields[2]) / 60
  return h + m
end

-- █▀▄▀█ █ █▀ █▀▀
-- █░▀░█ █ ▄█ █▄▄

--- @method fix_html
-- @brief Fixes stuff like:
-- &amp;  -> &
-- &apos; -> '
-- TODO is there a way to replace multiple MULTI-character patterns using a lookup tables?
function _string.fix_html(str)
  str = str:gsub("&amp;",  "&")
  str = str:gsub("&apos;", "'")
  str = str:gsub("&quot;", '"')
  str = str:gsub("&lt;",   "<")
  str = str:gsub("&gt;",   ">")
  return str
end

--- @method print_arr
-- @brief Pretty print array. Stolen from somewhere on StackOverflow
function _string.print_arr(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if (indentLevel == nil) then
    print(_string.print_arr(arr, 0))
    return
  end

  for _ = 0, indentLevel do
    indentStr = indentStr .. "  "
  end

  for index, value in pairs(arr) do
    if type(value) == "boolean" then
      value = value and "true" or "false"
    end

    if type(value) == "function" then
      value = "is a function"
    end

    if type(value) == "table" then
      str = str .. indentStr .. index .. ": \n" .. _string.print_arr(value, (indentLevel + 1))
    else
      str = str .. indentStr .. index .. ": " .. value .. "\n"
    end
  end
  return str
end

return _string
