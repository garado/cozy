
-- ▀█▀ █ █▀▄▀█ █▀▀ ░░▄▀ █▀▄ ▄▀█ ▀█▀ █▀▀
-- ░█░ █ █░▀░█ ██▄ ▄▀░░ █▄▀ █▀█ ░█░ ██▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")

local time = wibox.widget({
  format = "%l:%M %p", 
  font = beautiful.alt_font .. "25",
  align = "center",
  valign = "center",
  widget = wibox.widget.textclock
})

local time_color = wibox.container.background()
time_color:set_widget(time)
time_color:set_fg(beautiful.fg)

local date = wibox.widget({
  format = "%A %B %d", 
  font = beautiful.font_name .. "12",
  align = "center",
  valign = "center",
  widget = wibox.widget.textclock
})

local date_color = wibox.container.background()
date_color:set_widget(date)
date_color:set_fg(beautiful.timedate)

local widget = wibox.widget({
  {
    time_color,
    date_color,
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(10),
  widget = wibox.container.margin,
})

return helpers.ui.create_boxed_widget(widget, dpi(100), dpi(120), beautiful.dash_widget_bg)
