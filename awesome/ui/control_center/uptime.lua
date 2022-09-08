
-- █░█ █▀█ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄█ █▀▀ ░█░ █ █░▀░█ ██▄ 

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")

local cmd = 'bash -c "uptime -p"'
local w = awful.widget.watch(cmd, 5, function(widget, stdout)
  local text = helpers.ui.colorize_text(" " .. stdout, beautiful.ctrl_uptime)
  text = string.gsub(text, "up ", "")
  text = string.gsub(text, " day[s]?", "d")
  text = string.gsub(text, " hour[s]?", "h")
  text = string.gsub(text, " minute[s]?", "m")
  text = string.gsub(text, ",", "")
  widget:set_markup_silently(text)
end)

w.align = "left"
w.valign = "center"

return w
