
-- █▄▄ █▀█ █ █▀▀ █░█ ▀█▀ █▄░█ █▀▀ █▀ █▀
-- █▄█ █▀▄ █ █▄█ █▀█ ░█░ █░▀█ ██▄ ▄█ ▄█
--
-- █▀ █░░ █ █▀▄ █▀▀ █▀█
-- ▄█ █▄▄ █ █▄▀ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local naughty = require("naughty")
local animation = require("modules.animation")

return function()
  local slider = wibox.widget({
    {
      bar_shape = gears.shape.rounded_bar,
      bar_height = dpi(10),
      bar_color = beautiful.nord3,
      bar_active_color = beautiful.nord10,
      handle_width = dpi(0),
      value = 25,
      widget = wibox.widget.slider,
    },
    direction = "east",
    forced_height = dpi(0),
    widget = wibox.container.rotate,
  })

  local icon = wibox.widget({
    {
      markup = helpers.ui.colorize_text("滛", beautiful.nord10),
      widget = wibox.widget.textbox,
      font = beautiful.font .. "15",
      align = "center",
      valign = "center",
    },
    --margins = { top = dpi(5) },
    widget = wibox.container.margin,
  })

  local widget = wibox.widget({
    --{
      slider,
      icon,
      layout = wibox.layout.align.vertical,
    --},
    --margins = {
    --  bottom = dpi(10),
    --},
    --widget = wibox.container.margin,
  })

  -- Update brightness based on slider value 
  local brightness_slider = slider.children[1]
  brightness_slider:connect_signal("property::value", function()
    local brightness = brightness_slider:get_value()
  	awful.spawn("brightnessctl set " .. brightness .. "%", false)
    
    -- Update brightness osd
  	awesome.emit_signal("module::brightness_osd", brightness)
  end)
  
  -- WIP: update slider value based on volume
  
  -- Animations!!!
  local bar_animation = animation:new({
    duration = 0.12,
    easing = animation.easing.linear,
    reset_on_stop = true,
    update = function(self, pos)
      slider.forced_height = dpi(pos)
    end,
  })

  widget:connect_signal("mouse::enter", function()
    bar_animation:set(75)
  end)

  widget:connect_signal("mouse::leave", function()
    bar_animation:set(0)
  end)

  return widget
end
