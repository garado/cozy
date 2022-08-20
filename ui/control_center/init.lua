
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
  local screen_height = dpi(s.geometry.height)
  local screen_width = dpi(s.geometry.width)

  local profile = require("ui.control_center.profile")
  local quick_actions = require("ui.control_center.quick_actions")
  
  local control_center_contents = wibox.widget({
    {
      {
        profile,
        quick_actions,
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.background,
      bg = beautiful.dark_polar_night,
    },
    widget = wibox.container.margin,
  })

  -- Assemble the control center
  local control_center_width = dpi(300)
  local control_center_height = dpi(300)
  local control_center = awful.popup ({
    type = "dock",
    minimum_height = control_center_height,
    maximum_height = control_center_height,
    minimum_width = control_center_width,
    maximum_width = control_center_width,
    placement = awful.placement.bottom_left,
    bg = beautiful.transparent,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height)
    end,
    ontop = true,
    visible = false,
    widget = control_center_contents,
  })

  -- Keybind to toggle (default is Super_L + k)
  awesome.connect_signal("control_center::toggle", function()
    control_center.visible = not control_center.visible
  end)

  return control_center
end
