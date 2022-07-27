

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s)
  profile = wibox.widget({
    {
      markup = 'stats',
      widget = wibox.widget.textbox,
    },
    bg = beautiful.nord3,
    widget = wibox.container.background,
  })

  widget = wibox.widget({
    profile,
    margins = dpi(5),
    widget = wibox.container.margin,
  })
  return widget
end
