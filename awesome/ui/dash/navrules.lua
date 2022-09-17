
-- █▄░█ ▄▀█ █░█ █▀█ █░█ █░░ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▀▄ █▄█ █▄▄ ██▄ ▄█ 

-- Custom navigation rules for dashboard

local Navigator = require("ui.nav.navigator")
local navigator = Navigator:new()

local habit = {}
habit["j"] = function(index)
  if index > 28 then
    return -28
  else
    return 4
  end
end

habit["k"] = function(index)
  if index <= 4 then
    return 28
  else
    return -4
  end
end

habit["h"] = function(index)
  if (index - 1) % 4 == 0 then
    return 3
  else
    return -1
  end
end

habit["l"] = function(index)
  if index % 4 == 0 then
    return -3
  else
    return 1
  end
end

navigator.rules = {
  nav_dash_habits = {
    h = habit["h"],
    j = habit["j"],
    k = habit["k"],
    l = habit["l"],
  }
}

return navigator
