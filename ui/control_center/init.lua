
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local naughty = require("naughty")
local animation = require("modules.animation")

return function(s)
  -- Variables
  local screen_height = dpi(s.geometry.height)
  local screen_width = dpi(s.geometry.width)
  
  local widget = wibox.widget({
    {
      markup = "Control center wip",
      widget = wibox.widget.textbox
    },
    widget = wibox.container.background,
    bg = beautiful.dark_polar_night,
  })

  -- Assemble the control center
  local control_center_width = dpi(300)
  local control_center = awful.popup ({
    type = "dock",
    minimum_height = screen_height,
    maximum_height = screen_height,
    minimum_width = control_center_width,
    maximum_width = control_center_width,
    bg = beautiful.nord3,
    ontop = true,
    visible = false,
    widget = widget,
  })


  -- Sliding animation
  control_center.x = screen_width + control_center_width
  local isOpen = false
  local control_center_anim = animation:new({
    duration = 0.12,
    easing = animation.easing.inOutQuad,
    update = function(self, pos)
      control_center.x = screen_width - dpi(pos)
      if dpi(pos) == 0 and isOpen then
        control_center.visible = false
      end
    end
  })
  
  -- Keybind to toggle (default is Super_L + k)
  awesome.connect_signal("control_center::toggle", function()
    if control_center.visible then
      control_center_anim:set(0)
    else
      control_center.visible = true
      control_center_anim:set(300)
    end
    isOpen = not isOpen
  end)

  return control_center
end
