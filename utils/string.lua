
-- █▀ ▀█▀ █▀█ █ █▄░█ █▀▀    █░█ ▀█▀ █ █░░ █▀ 
-- ▄█ ░█░ █▀▄ █ █░▀█ █▄█    █▄█ ░█░ █ █▄▄ ▄█ 

local string = string -- Lua library

local _string = {}

-- █▀▄▀█ ▄▀█ █▄░█ █ █▀█ █░█ █░░ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- █░▀░█ █▀█ █░▀█ █ █▀▀ █▄█ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ 

--- @brief Capitalize the first letter of the string
function _string.first_to_upper(str)
  return (str:gsub("^%l", string.upper))
end

--- @brief Split text input on a given delimiter.
-- @param text  A string to delimit.
-- @param delim Delimiting character(s)
-- @param keepEmpty True if empty tokens should be kept (stored
-- in return array as "")
-- @return A table containing the split tokens.
function _string.split(text, delim, keepEmpty)
  delim = delim or "%s" -- default all whitespace
  keepEmpty = keepEmpty or false

  local match
  if keepEmpty then
    text  = text .. delim
    match = "([^"..delim.."]*)" .. delim
  else
    match = "([^"..delim.."]+)"
  end

  local ret = {}
  for str in text:gmatch(match) do
    ret[#ret + 1] = str
  end
  return ret
end

--- Check if string starts with another string
-- @param text    Text to search through
-- @param prefix  Text to look for
function _string.hasprefix(text, prefix)
   return string.sub(text, 1, string.len(prefix)) == prefix
end

--- Check if string contains a substring
function _string.contains(str, target)
  return string.find(str, target)
end


-- █▀▄ ▄▀█ ▀█▀ █▀▀    ▄▀█ █▄░█ █▀▄    ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄▀ █▀█ ░█░ ██▄    █▀█ █░▀█ █▄▀    ░█░ █ █░▀░█ ██▄ 

--- @method date_to_int
-- @brief   Convert date from gcalcli (YYYY-MM-DD or YYYY-MM-DD\t\tHH:MM) to a timestamp
-- @return  An os.time timestamp
function _string.datetime_to_ts(datetime)
  local time_specified = _string.contains(datetime, ":")

  if time_specified then
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)\t\t(%d%d:%d%d)"
    local xyear, xmon, xday, xhr, xmin = datetime:match(pattern)
    return os.time({
      year = xyear, month = xmon, day = xday,
      hour = xhr, min = xmin, sec = 0})
  else
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
    local xyear, xmon, xday = datetime:match(pattern)
    return os.time({
      year = xyear, month = xmon, day = xday,
      hour = 0, min = 0, sec = 0})
  end
end

--- @method datetime_to_human
-- @brief Convert YYYY-MM-DD to human-readable date.
-- i.e. 2023-05-14 to Sunday, May 14 2023
function _string.datetime_to_human(datetime)
  local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
  local xyear, xmon, xday = datetime:match(pattern)
  local ts = os.time({
      year = xyear, month = xmon, day = xday,
      hour = 0, min = 0, sec = 0})
  return os.date("%A, %B %d %Y", ts)
end

--- @method time_to_int
-- @param time  A time in format HH:MM (military time)
-- Converts time in HH:MM to an integer 0-24.
-- Example: 23:15 -> 23.25
function _string.time_to_int(time)
  local fields = _string.split(time, ":")
  local h = tonumber(fields[1])
  local m = tonumber(fields[2]) / 60
  return h + m
end

--- @method day_to_int
-- @param date  A date in the form YYYY-MM-DD
-- @brief Convert a date to a weekday 0-6.
function _string.date_to_weekday_int(date)
  local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
  local xyear, xmon, xday = date:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = 0, min = 0, sec = 0})
  return os.date("%w", ts)
end

--- @method iso_to_ts
-- @brief Converts ISO-8601-formatted date (as used by Taskwarrior
-- and Timewarrior) to an os.time timestamp.
function _string.iso_to_ts(iso)
  -- ISO-8601 format: YYYY-MM-DDThh:mm:ssZ
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = iso:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })

  -- Account for timezone (america/los_angeles: -8 hours)
  ts = ts - (7 * 60 * 60)

  return ts
end

--- @method iso_to_readable
-- @brief Converts ISO-8601 format dates (as used by Taskwarrior
-- and Timewarrior) into human-readable dates.
-- @param iso     (string) ISO-formatted date
-- @param format  
function _string.iso_to_readable(iso, format)
  local ts = _string.iso_to_ts(iso)
  format = format or '%A %B %d %Y'
  return os.date(format, ts)
end

--- @method iso_to_relative
-- @brief Converts ISO-8601 format dates (as used by Task/Timewarrior)
-- into a relative date (i.e. 'in 3 days', '3 days ago')
-- @return (string) The relative date
-- @return (bool) If task is overdue
function _string.iso_to_relative(iso)
  local ts = _string.iso_to_ts(iso)
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


-- █▀█ ▄▀█ █▄░█ █▀▀ █▀█ 
-- █▀▀ █▀█ █░▀█ █▄█ █▄█ 

function _string.pango_bold(str)
  if not str then return end
  return "<b>"..str.."</b>"
end

-- █▀▄▀█ █ █▀ █▀▀ 
-- █░▀░█ █ ▄█ █▄▄ 

--- @method print_arr
--@brief Pretty print array
function _string.print_arr(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if (indentLevel == nil) then
    print(_string.print_arr(arr, 0))
    return
  end

  for _ = 0, indentLevel do
    indentStr = indentStr.."  "
  end

  for index,value in pairs(arr) do
    if type(value) == "boolean" then
      value = value and "true" or "false"
    end

    if type(value) == "function" then
      value = "is a function"
    end

    if type(value) == "table" then
      str = str..indentStr..index..": \n".._string.print_arr(value, (indentLevel + 1))
    else
      str = str..indentStr..index..": "..value.."\n"
    end
  end
  return str
end

return _string
