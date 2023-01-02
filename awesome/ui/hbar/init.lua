
-- █░█ █▄▄ ▄▀█ █▀█ 
-- █▀█ █▄█ █▀█ █▀▄ 

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local clock   = require(... .. ".clock")
local taglist = require(... .. ".taglist")
local battery = require(... .. ".battery")
local notif   = require(... .. ".notif")

return function(s)
  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_width  = s.geometry.width,
    maximum_width  = s.geometry.width,
    minimum_height = dpi(35),
    maximum_height = dpi(35),
    placement = awful.placement.top,
    widget = {
      {
        {
          {
            clock,
            spacing = dpi(10),
            layout  = wibox.layout.fixed.horizontal,
          },
          taglist(s),
          {
            notif,
            battery,
            clock,
            spacing = dpi(10),
            layout  = wibox.layout.fixed.horizontal,
          },
          expand = "none",
          layout = wibox.layout.align.horizontal,
        },
        left   = dpi(15),
        right  = dpi(15),
        widget = wibox.container.margin,
      },
      bg     = beautiful.wibar_bg,
      widget = wibox.container.background,
    }
  })

  -- reserve screen space
  s.bar:struts({
    top = s.bar.maximum_height,
  })

  -- SETTINGS --
  -- Bar visibility
  local function remove_bar(c)
    if c.fullscreen or c.maximized then
      c.screen.bar.visible = false
    else
      c.screen.bar.visible = true
    end
  end

  -- i dont really understand this one
  local function add_bar(c)
    if c.fullscreen or c.maximized then
      c.screen.bar.visible = true
    end
  end
end
