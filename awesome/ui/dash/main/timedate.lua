
-- ▀█▀ █ █▀▄▀█ █▀▀ ░░▄▀ █▀▄ ▄▀█ ▀█▀ █▀▀
-- ░█░ █ █░▀░█ ██▄ ▄▀░░ █▄▀ █▀█ ░█░ ██▄

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local box = require("helpers.ui").create_boxed_widget

local time = wibox.widget({
  format  = "%l:%M %p",
  font    = beautiful.alt_large_font,
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textclock
})

local time_color = wibox.container.background()
time_color:set_widget(time)
time_color:set_fg(beautiful.fg)

local date = wibox.widget({
  format  = "%A %B %d",
  font    = beautiful.base_small_font,
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textclock
})

local date_color = wibox.container.background()
date_color:set_widget(date)
date_color:set_fg(beautiful.timedate)

local widget = wibox.widget({
  {
    {
      time_color,
      date_color,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  },
  margins = dpi(10),
  widget = wibox.container.margin,
})

return box(widget, dpi(100), dpi(120), beautiful.dash_widget_bg)
