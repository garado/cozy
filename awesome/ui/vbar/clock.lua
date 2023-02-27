
-- █▄▄ ▄▀█ █▀█ ▀   █▀▀ █░░ █▀█ █▀▀ █▄▀
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▄▄ █▄█ █▄▄ █░█

local wibox = require("wibox")
local beautiful = require("beautiful")

local clock = wibox.widget({
  format  = "%H\n%M",
  align   = "center",
  valign  = "center",
  font    = beautiful.font_reg_xs,
  widget  = wibox.widget.textclock,
})

local clock_color = wibox.container.background()
clock_color:set_widget(clock)
clock_color:set_fg(beautiful.wibar_fg)

return clock_color
