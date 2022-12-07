
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- Displays clock icon

local beautiful = require("beautiful")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local colorize = require("helpers").ui.colorize_text

local icon = wibox.widget({
  markup = colorize("", beautiful.wibar_fg),
  font   = beautiful.font_name .. "13",
  widget = wibox.widget.textbox,
})

awesome.connect_signal("bar::show_timewarrior", function()
  icon.visible = true
end)

awesome.connect_signal("bar::hide_timewarrior", function()
  icon.visible = false
end)

local widget = wibox.widget({
  icon,
  widget = wibox.container.place,
})

awesome.connect_signal("bar::show_timewarrior", function()
  widget.visible = true
end)

awesome.connect_signal("bar::hide_timewarrior", function()
  widget.visible = false
end)


return widget
