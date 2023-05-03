
-- █▀ ▀█▀ █▀█ █ █▄░█ █▀▀    █░█ ▀█▀ █ █░░ █▀ 
-- ▄█ ░█░ █▀▄ █ █░▀█ █▄█    █▄█ ░█░ █ █▄▄ ▄█ 

local string = string -- Lua library

local _string = {}

-- █▀▄▀█ ▄▀█ █▄░█ █ █▀█ █░█ █░░ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- █░▀░█ █▀█ █░▀█ █ █▀▀ █▄█ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ 

--- Split text input on a given character(s).
-- @param text  A string to delimit.
-- @param delim Delimiting characters
-- @return A table containing the split tokens.
function _string.split(text, delim)
  delim = delim or "%s" -- default all whitespace 
  local ret = {}
  for str in text:gmatch("([^"..delim.."]+)") do
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

    if type(value) == "table" then
      str = str..indentStr..index..": \n".._string.print_arr(value, (indentLevel + 1))
    else
      str = str..indentStr..index..": "..value.."\n"
    end
  end
  return str
end

return _string
