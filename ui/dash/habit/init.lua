
-- █▀▄ ▄▀█ █▀ █░█ ▀   █░█ ▄▀█ █▄▄ █ ▀█▀
-- █▄▀ █▀█ ▄█ █▀█ ▄   █▀█ █▀█ █▄█ █ ░█░

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s)
  widget = {
    {
      markup = 'habit',
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    bg = "bf616a",
    forced_width = dpi(300),
    forced_height = dpi(300), 
    widget = wibox.container.background,
  } -- end widget
  return widget
end
