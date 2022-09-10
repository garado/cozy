
-- █▀▄ ▄▀█ █▀ █░█ ▀    ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
-- █▄▀ █▀█ ▄█ █▀█ ▄    █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local calendar = require("ui.dash.agenda.calendar")

local widget = wibox.widget({
  {
    calendar,
    layout = wibox.layout.fixed.horizontal,
  },
  bg = "bf616a",
  forced_width = dpi(300),
  forced_height = dpi(300),
  widget = wibox.container.background,
}) -- end widget

return widget
