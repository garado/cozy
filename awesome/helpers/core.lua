
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

return core
