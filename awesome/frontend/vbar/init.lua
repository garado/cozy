
-- █░█ █▄▄ ▄▀█ █▀█ 
-- ▀▄▀ █▄█ █▀█ █▀▄ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local logo = require(... .. ".logo")
local clock = require(... .. ".clock")
local taglist = require(... .. ".taglist")

local top_vbar = wibox.widget({
  logo,
  layout = wibox.layout.fixed.vertical,
})

local bottom_vbar = wibox.widget({
  clock,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

return function(s)
  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_height = s.geometry.height,
    maximum_height = s.geometry.height,
    minimum_width = dpi(40),
    maximum_width = dpi(40),
    placement = awful.placement.left,
    widget = {
      {
        {
          { -- Top
            top_vbar,
            top = dpi(8),
            widget = wibox.container.margin,
          },
          taglist(s), -- Middle
          { -- Bottom
            bottom_vbar,
            bottom = dpi(6),
            widget = wibox.container.margin,
          },
          layout = wibox.layout.align.vertical,
          expand = "none",
        },
        margins = dpi(3),
        widget  = wibox.container.margin,
      },
      bg      = beautiful.wibar_bg,
      widget  = wibox.container.background,
    },
  })

  -- Reserve screen space
  s.bar:struts({
    left = s.bar.maximum_width,
  })
end
