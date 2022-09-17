
-- █▄░█ ▄▀█ █░█ █▀█ █░█ █░░ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▀▄ █▄█ █▄▄ ██▄ ▄█ 

-- Custom keynav rules for control center

local Navigator = require("ui.nav.navigator")
local navigator = Navigator:new()

-- Quick actions are a 2x5 grid
local qactions = {}
qactions["j"] = function(index)
  if index <= 5 then
    return 5, false
  elseif index > 5 and index < 9 then
    navigator:set_area("links")
    navigator.curr_area.index = 1
    return 0, true
  else
    navigator:set_area("links")
    navigator.curr_area.index = 2
    return 0, true
  end
end

qactions["k"] = function(index)
  if index > 5 then
    return -5, false
  else
    navigator:set_area("power_opts")
    return 0, true
  end
end

qactions["h"] = function(index)
  if index == 1 or index == 6 then
    navigator.curr_area.index = navigator.curr_area.index + 4
    return 0, true
  else
    return -1, false
  end
end

qactions["l"] = function(index)
  if index == 5 or index == 10 then
    navigator.curr_area.index = navigator.curr_area.index - 4
    return 0, true
  else
    return 1, false
  end
end

-- Links are a 3x2 grid
local links = {}
links["j"] = function(index)
  if index < 5 then
    return 2, false
  else
    navigator:set_area("power_opts")
    navigator.curr_area.index = 1
    return 0, true
  end
end

links["k"] = function(index)
  if index == 1 then
    navigator:set_area("qactions")
    navigator.curr_area.index = 6
    return 0, true
  elseif index == 2 then
    navigator:set_area("qactions")
    navigator.curr_area.index = 10
    return 0, true
  else
    return -2, false
  end
end

local power_opts = {}
local function links_horizontal(index)
  if index % 2 == 1 then
    return 1, false
  else
    return -1, false
  end
end

power_opts["j"] = function(_)
  navigator:iter_between_areas(1)
  return 0, true
end

power_opts["k"] = function(_)
  navigator:set_area("links")
  navigator.curr_area.index = 6
  return 0, true
end

local power_confirm = {}
power_confirm["j"] = function(_)
  navigator:iter_between_areas(1)
  return 0, true
end

power_confirm["k"] = function(_)
  navigator:iter_between_areas(-1)
  return 0, true
end

navigator.rules = {
  qactions = {
    h = qactions["h"],
    j = qactions["j"],
    k = qactions["k"],
    l = qactions["l"],
  },
  links = {
    h = links_horizontal,
    j = links["j"],
    k = links["k"],
    l = links_horizontal,
  },
  power_opts = {
    j = power_opts["j"],
    k = power_opts["k"],
  },
  power_confirm = {
    j = power_confirm["j"],
    k = power_confirm["k"],
  },
}

return navigator
