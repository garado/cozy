
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- A dashboard tab for viewing and modifying Timewarrior stats.

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local ui     = require("helpers.ui")
local keynav = require("modules.keynav")

-- local cal, nav_cal = require(... .. ".time.calendar")()
local cal     = require(... .. ".calendar")
local list    = require(... .. ".list")
local infobox, nav_infobox = require(... .. ".infobox")()

local nav_timewarrior = keynav.area({
  name = "agenda",
  children = {
    nav_infobox,
  },
})

-- local tags  = require(... .. ".tags")
-- local stats = require(... .. ".stats")


local timewarrior = wibox.widget({
  {
    {
      {
        markup = ui.colorize("Timewarrior", beautiful.fg_0),
        align  = "center",
        valign = "center",
        font   = beautiful.font_med_l,
        widget = wibox.widget.textbox,
      },
      top    = dpi(10),
      widget = wibox.container.margin,
    },
    cal,
    infobox,
    layout = wibox.layout.fixed.vertical,
  },
  list,
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return timewarrior, nav_timewarrior
end
