
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local dash = require("helpers.dash")
local beautiful = require("beautiful")
local gears = require("gears")

return function(task_obj)
  local widget = wibox.widget({
    {
      {
        {
          dash.widget_header("Stats"),
          spacing = dpi(10),
          forced_width = dpi(150),
          layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place
    },
    forced_height = dpi(50),
    forced_width = dpi(270),
    bg = beautiful.dash_widget_bg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
  return widget
end
