
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- See monthly calendar, today's schedule, and upcoming deadlines

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keynav = require("modules.keynav")

local infobox, nav_infobox  = require(... .. ".infobox")()
local calendar, nav_cal     = require(... .. ".calendar")()
local threeday, nav_threeday = require(... .. ".threedaygroup")()

local nav_overview = keynav.area({
  name = "nav_overview",
  children = {
    nav_cal,
    nav_infobox,
    -- nav_threeday
  },
})

local overview_contents = wibox.widget({
  {
    calendar,
    infobox,
    layout = wibox.layout.fixed.vertical,
  },
  threeday,
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return overview_contents, nav_overview
end
