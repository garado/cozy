-- █▀▀ █░░ █▀█ █▀▀ █▄▀
-- █▄▄ █▄▄ █▄█ █▄▄ █░█

local conf = require("cozyconf")
local wibox = require("wibox")
local beautiful = require("beautiful")

local clock = wibox.widget({
  format = "%A %d %Y  %H:%M",
  align  = "center",
  valign = "center",
  font   = beautiful.font_reg_xs,
  widget = wibox.widget.textclock,
})

local clock_color = wibox.container.background()
clock_color:set_widget(clock)
clock_color:set_fg(conf.pulsebar_fg_r == "dark" and beautiful.neutral[900] or beautiful.neutral[100])

return clock_color
