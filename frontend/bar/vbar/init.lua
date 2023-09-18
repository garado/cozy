
-- █░█ █▄▄ ▄▀█ █▀█ 
-- ▀▄▀ █▄█ █▀█ █▀▄ 

local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("utils.ui").dpi
local beautiful  = require("beautiful")
local conf = require("cozyconf")

local logo    = require("frontend.bar.common.logo")
local clock   = require("frontend.bar.common.clock")("%H\n%M")
local battery = require("frontend.bar.common.battery")
local taglist = require(... .. ".taglist")

local align = (conf.bar_align == "right") and "right" or "left"

return function(s)
  local systray = require("frontend.bar.common.systray")(s)

  local top_vbar = wibox.widget({
    logo,
    layout = wibox.layout.fixed.vertical,
  })

  local bottom_vbar = wibox.widget({
    battery,
    clock,
    conf.show_systray and systray,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })

  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_height = s.geometry.height,
    maximum_height = s.geometry.height,
    minimum_width = dpi(40),
    maximum_width = dpi(40),
    placement = awful.placement[align],
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
      bg      = beautiful.neutral[900],
      widget  = wibox.container.background,
    },
  })

  -- Reserve screen space
  s.bar:struts({
    [align] = s.bar.maximum_width,
  })

  systray.screen_name = s.name
  systray.bar = s.bar
end
