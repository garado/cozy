
-- █▀▀ █▀█ █▀█ █▀▀    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀
-- █▄▄ █▄█ █▀▄ ██▄    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█

-- Some helper functions that I found useful for data wrangling.

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
    if type(value) == "table" then
      str = str..indentStr..index..": \n"..core.print_arr(value, (indentLevel + 1))
    else
      str = str..indentStr..index..": "..value.."\n"
    end
  end
  return str
end

return core
