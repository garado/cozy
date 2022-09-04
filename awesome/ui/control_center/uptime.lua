
-- █░█ █▀█ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄█ █▀▀ ░█░ █ █░▀░█ ██▄ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local widgets = require("ui.widgets")

local cmd = 'bash -c "uptime -p"'
local w = awful.widget.watch(cmd, 5, function(widget, stdout)
  local text = helpers.ui.colorize_text(" " .. stdout, beautiful.ctrl_uptime)
  text = string.gsub(text, "up ", "")
  widget:set_markup_silently(text)
end)

w.align = "left"
w.valign = "center"

return w
