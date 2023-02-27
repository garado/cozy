
-- █░█░█ █░█ █▀▀ █▀█ █▀▀ ▀ █▀    ▀█▀ █░█ █▀▀    █▀▄ ▄▀█ █▀▄▀█ █▄░█    █▄▄ █░█ █▀ ▀█ 
-- ▀▄▀▄▀ █▀█ ██▄ █▀▄ ██▄ ░ ▄█    ░█░ █▀█ ██▄    █▄▀ █▀█ █░▀░█ █░▀█    █▄█ █▄█ ▄█ ░▄ 

-- SCMTD bus tracker because I hate waiting and CruzMetro takes too many clicks.

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local buscore = require("core.web.bus")
local keynav  = require("modules.keynav")

local select, nav_select = require(... .. ".select")()
local track, nav_track   = require(... .. ".track")()

local views = { select, track }
local nav_views = { nav_select, nav_track }

local bus = wibox.widget({
  select,
  widget = wibox.container.place,
})

local bus_cont = ui.box(bus, dpi(300), dpi(600), beautiful.dash_widget_bg)

local nav_bus = keynav.area({
  name     = "bus",
  circular = true,
  children = {
    nav_select,
  },
})

buscore:connect_signal("view::switch", function(_, view)
  bus.widget = views[view]
  nav_bus:reset()
  nav_bus:append(nav_views[view])
end)

return function()
  return bus_cont, nav_bus
end
