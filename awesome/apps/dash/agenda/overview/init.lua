
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- See monthly calendar, today's schedule, and upcoming deadlines

local wibox = require("wibox")
local gears = require("gears")
local box   = require("helpers").ui.create_boxed_widget
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keynav = require("modules.keynav")

local infobox, nav_infobox  = require(... .. ".infobox")()
local calendar, nav_cal     = require(... .. ".calendar")()

local nav_overview = keynav.area({
  name = "nav_overview",
  children = {
    nav_cal,
    nav_infobox,
  },
})

local overview_contents = wibox.widget({
  {
    calendar,
    infobox,
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return overview_contents, nav_overview
end
