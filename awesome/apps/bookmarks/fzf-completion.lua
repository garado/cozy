
-- █▀▀ ▀█ █▀▀  █▀▀ █▀█ █▀▄▀█ █▀█ █░░ █▀▀ ▀█▀ █ █▀█ █▄░█ 
-- █▀░ █▄ █▀░  █▄▄ █▄█ █░▀░█ █▀▀ █▄▄ ██▄ ░█░ █ █▄█ █░▀█ 

-- generic completion but with fzf

local math = math
local fzf = require("modules.fzy_lua")
local bm  = require("core.cozy.bookmarks")
local bmarks = require("cozyconf.bookmarks")
local beautiful = require("beautiful")

local completion = {}

--- Run a generic completion.
-- For this function to run properly the awful.completion.keyword table should
-- be fed up with all keywords. The completion is run against these keywords.
-- @tparam string text The current text the user had typed yet.
-- @tparam number cur_pos The current cursor position.
-- @tparam number ncomp The number of yet requested completion using current text.
-- @tparam table keywords The keywords table used for completion.
-- @treturn string The new match.
-- @treturn number The new cursor position.
-- @treturn table The table of all matches.
-- @staticfct awful.completion.generic
function completion.fzf(text, cur_pos, ncomp, keywords) -- luacheck: no unused args
  -- The keywords table may be empty
  if #keywords == 0 then
    return text, #text + 1
  end

  -- if no text had been typed yet, then we could start cycling around all
  -- keywords with out filtering and move the cursor at the end of keyword
  if text == nil or #text == 0 then
    ncomp = math.fmod(ncomp - 1, #keywords) + 1
    return keywords[ncomp], #keywords[ncomp] + 2
  end

  -- Filter out only keywords starting with text
  local matches = {}
  local fzf_matches = fzf.filter(text, keywords)
  for i = 1, #fzf_matches do
    local idx = fzf_matches[i][1]
    matches[#matches+1] = keywords[idx]
  end

  -- Highlight matching wiboxes 
  if #matches == 0 then
    bm.content:set_all_fg(beautiful.fg_0)
  else
    bm.content:set_all_fg(beautiful.bg_5)
    for i = 1, #matches do
      local title = matches[i]
      for _, links in pairs(bmarks) do
        for j = 1, #links do
          if links[j][bm._TITLE] == title then
            links[j][bm._WIBOX]:set_fg(beautiful.fg_0)
            goto continue
          end
        end
        ::continue::
      end
    end
  end

  -- if there are no matches just leave out with the current text and position
  if #matches == 0 then
    return text, #text + 1, matches
  end

  --  cycle around all matches
  ncomp = math.fmod(ncomp - 1, #matches) + 1
  return matches[ncomp], #matches[ncomp] + 1, matches
end

return completion
