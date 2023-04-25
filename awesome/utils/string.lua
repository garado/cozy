
-- █▀ ▀█▀ █▀█ █ █▄░█ █▀▀    █░█ ▀█▀ █ █░░ █▀ 
-- ▄█ ░█░ █▀▄ █ █░▀█ █▄█    █▄█ ░█░ █ █▄▄ ▄█ 

local _string = {}


--- Split text input on a given character(s).
-- @param text  A string to delimit.
-- @param delim Delimiting characters
-- @return A table containing the split tokens.
function string.split(text, delim)
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
function string.hasprefix(text, prefix)
   return string.sub(text, 1, string.len(prefix)) == prefix
end

--- Pretty print array
function string.print_arr(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if (indentLevel == nil) then
    print(string.print_arr(arr, 0))
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
      str = str..indentStr..index..": \n"..string.print_arr(value, (indentLevel + 1))
    else
      str = str..indentStr..index..": "..value.."\n"
    end
  end
  return str
end

-- Timewarrior reports time in H+:MM:SS format (6:15:08)
-- But I prefer it in 6h 15m format.
function string.format_time(str)
  -- remove whitespace and seconds
  str = string.gsub(str, "[%a+%s+\n\r]", "")
  str = string.gsub(str, ":%d+$", "")

  local min_str  = string.gsub(str, "^%d+:", "")
  local hour_str = string.gsub(str, ":%d+$", "")
  local min  = tonumber(min_str) or 0
  local hour = tonumber(hour_str)

  local txt = "--"
  local valid_hour = hour and hour > 0
  if min_str  then txt = min .. "m" end
  if valid_hour then txt = hour .. "h " .. txt end

  return txt
end

function string.datestr_to_ts(datestring)
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = datestring:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })
  ts = ts - (8 * 60 * 60) -- pacific time is 8 hours behind utc
  return ts
end

function string.ts_str_to_ts(str)
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = str:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })

  -- Account for timezone (america/los_angeles: -8 hours)
  ts = ts - (8 * 60 * 60)

  return ts
end

function string.format_due_date(due)
  if not due or due == "" then return "no due date" end
  local ts = string.ts_str_to_ts(due)

  -- turn timestamp into human-readable format
  local now = os.time()
  local time_difference = ts - now
  local abs_time_difference = math.abs(time_difference)
  local days_rem = math.floor(abs_time_difference / 86400)
  local hours_rem = math.floor(abs_time_difference / 3600)

  -- due date formatting
  local due_date_text
  if days_rem >= 1 then -- in x days / x days ago
    due_date_text = days_rem .. " day"
    if days_rem > 1 then
      due_date_text = due_date_text .. "s"
    end
  else -- in x hours / in <1 hour / etc
    if hours_rem == 1 then
      due_date_text = hours_rem .. " hour"
    elseif hours_rem < 1 then
      due_date_text = "&lt;1 hour"
    else
      due_date_text = hours_rem .. " hours"
    end
  end

  local due_date_color
  -- local due_date_color = beautiful.fg_sub
  -- if time_difference < 0 then -- overdue
  --   due_date_text = due_date_text .. " ago"
  --   due_date_color = beautiful.red
  -- else
  --   due_date_text = "in " .. due_date_text
  -- end

  return due_date_text, due_date_color
end

return string
