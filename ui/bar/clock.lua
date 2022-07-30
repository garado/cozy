
-- █▄▄ ▄▀█ █▀█ ▀   █▀▀ █░░ █▀█ █▀▀ █▄▀
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▄▄ █▄█ █▄▄ █░█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

return function(s)
  local clock = wibox.widget({
    format = "%H\n%M",
    align = "center",
    valign = "center",
    font = beautiful.font_name .. "Medium 10",
    widget = wibox.widget.textclock,
  })

  local clock_color = wibox.widget.background()
  clock_color:set_widget(clock)
  clock_color:set_fg(beautiful.xforeground)

  return wibox.widget ({
    clock_color,
    margins = dpi(6),
    widget = wibox.container.margin,
  })
end
