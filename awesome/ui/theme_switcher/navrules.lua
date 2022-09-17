
-- █▄░█ ▄▀█ █░█ █▀█ █░█ █░░ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▀▄ █▄█ █▄▄ ██▄ ▄█ 

local Navigation = require("ui.nav.navigator")
local navigator = Navigation:new()

local row = {}

row["h"] = function(index)
  if index == 1 then
    navigator.curr_area.index = #navigator.curr_area.items
    return 0, true
  else
    return -1
  end
end

row["l"] = function(index)
  if index == #navigator.curr_area.items then
    navigator.curr_area.index = 1
    return 0, true
  else
    return 1
  end
end

row["j"] = function(_)
  navigator:iter_between_areas(1)
  return 0, true
end

row["k"] = function(_)
  navigator:iter_between_areas(-1)
  return 0, true
end

navigator.rules = {
  nav_styles = {
    h = row["h"],
    j = row["j"],
    l = row["l"],
    k = row["k"],
  },
  nav_actions = {
    h = row["h"],
    j = row["j"],
    l = row["l"],
    k = row["k"],
  }
}

return navigator
