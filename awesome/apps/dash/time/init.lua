
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- A dashboard tab for viewing and modifying Timewarrior stats.

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local colorize  = require("helpers.ui").colorize_text

-- local cal, nav_cal = require(... .. ".time.calendar")()
local cal   = require(... .. ".calendar")
local list  = require(... .. ".list")
local tags  = require(... .. ".tags")
local stats = require(... .. ".stats")

local time_dash = wibox.widget({
  {
    {
      {
        markup = colorize("Timewarrior", beautiful.fg),
        align  = "center",
        valign = "center",
        font   = beautiful.alt_xlarge_font,
        widget = wibox.widget.textbox,
      },
      top    = dpi(10),
      widget = wibox.container.margin,
    },
    cal,
    stats,
    layout = wibox.layout.fixed.vertical,
  },
  list,
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return time_dash
end
