
-- █▀▄ ▄▀█ █▀ █░█ ▀    ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
-- █▄▀ █▀█ ▄█ █▀█ ▄    █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local calendar  = require("ui.dash.agenda.calendar")
local upcoming  = require("ui.dash.agenda.upcoming")
local deadlines = require("ui.dash.agenda.deadlines")

local header = wibox.widget({
  markup = colorize("This week", beautiful.main_accent),
  font = beautiful.alt_font_name .. "Light 30",
  align = "center",
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  {
    header,
    calendar,
    deadlines,
    layout = wibox.layout.fixed.vertical,
  },
  {
    upcoming,
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return widget
