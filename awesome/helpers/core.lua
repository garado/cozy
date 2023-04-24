
-- █▀▀ █▀█ █▀█ █▀▀    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀
-- █▄▄ █▄█ █▀▄ ██▄    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█

-- Some helper functions that I found useful for data wrangling.

local colorize = require("helpers.ui").colorize_text

local core = {}

--- Split text input on a given character(s).
-- @param char Delimiting characters
-- @param text A string to delimit.
-- @return A table containing the split tokens.
function core.split(char, text)
  char = char or "%s" -- default all whitespace 
  local ret = {}
  for str in text:gmatch("([^"..char.."]+)") do
    ret[#ret + 1] = str
  end
  return ret
end

--- Check if string starts with another string
-- @param text Text to search through
-- @param start_text Text to look for
function core.starts(text, start_text)
   return string.sub(text, 1, string.len(start_text)) == start_text
end

-- function core.remove_prefix(prefix, text)
--   local str_stripped = string.gsub(str, "[^0-9$.]", "")
-- end
-- 
-- function core.remove_char(char, text)
--   return string.gsub(text, "[^]", "")
-- end

--- Pretty print array
function core.print_arr(arr, indentLevel)
  local str = ""
  local indentStr = "#"

  if (indentLevel == nil) then
    print(core.print_arr(arr, 0))
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
      str = str..indentStr..index..": \n"..core.print_arr(value, (indentLevel + 1))
    else
      str = str..indentStr..index..": "..value.."\n"
    end
  end
  return str
end

function core.pango_bold(text, color)
  text = "<b>" .. text .. "</b>"
  return colorize(text, color)
end

-- Timewarrior reports time in H+:MM:SS format (6:15:08)
-- But I prefer it in 6h 15m format.
function core.format_time(str)
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

return core
