
-- █▄▄ ▄▀█ █▀█ ▀   █▀▀ █░░ █▀█ █▀▀ █▄▀
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▄▄ █▄█ █▄▄ █░█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")

local clock = wibox.widget({
  format = "%H\n%M",
  align = "center",
  valign = "center",
  font = beautiful.font_name .. "Medium 10",
  widget = wibox.widget.textclock,
})

local clock_color = wibox.container.background()
clock_color:set_widget(clock)
clock_color:set_fg(beautiful.wibar_clock)

return clock_color
