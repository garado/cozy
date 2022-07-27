
-- █▄▄ ▄▀█ █▀█ ▀   █▀▀ █░░ █▀█ █▀▀ █▄▀
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▄▄ █▄█ █▄▄ █░█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s)
  local clock = wibox.widget({
    format = "%H\n%M",
    align = "center",
    valign = "center",
    font = beautiful.font_name .. "Medium 10",
    widget = wibox.widget.textclock,
  })

  return wibox.widget ({
    clock,
    margins = dpi(6),
    widget = wibox.container.margin,
  })
end
