
-- ▀█▀ █ █▀▄▀█ █▀▀ 
-- ░█░ █ █░▀░█ ██▄ 

local ui    = require("utils.ui")
local wibox = require("wibox")
local dash  = require("backend.cozy.dash")
local time  = require("backend.system.time")
local keynav = require("modules.keynav")

local tmp

local states = {
  idle   = require(... .. ".idle"),
  select = require(... .. ".select"),
  type   = require(... .. ".type"),
  active = require(... .. ".active"),
}

local contents = wibox.widget({
  states["idle"],
  widget = wibox.container.place,
})

dash:connect_signal("main::time::changestate", function(_, state)
  contents.widget = states[state]

  tmp.keynav.keys = states[state].keys
  tmp.keynav:clear()
  if states[state].navitems then
    for i = 1, #states[state].navitems do
      tmp.keynav:append(states[state].navitems[i])
    end
  end
end)

time:connect_signal("tracking::active", function()
  contents.widget = states["active"]
  tmp.keys = states["active"].keys or {}
end)

local container = ui.dashbox_v2(contents)
tmp = ui.rrborder(container)

tmp.keynav = keynav.area({
  name   = "nav_time",
  widget = tmp,
  keys   = states["idle"].keys
})

return tmp
