
-- █░█ █▀█ █░░ █░█ █▀▄▀█ █▀▀   █▀ █░░ █ █▀▄ █▀▀ █▀█
-- ▀▄▀ █▄█ █▄▄ █▄█ █░▀░█ ██▄   ▄█ █▄▄ █ █▄▀ ██▄ █▀▄

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
      id = "slider",
      bar_shape = gears.shape.rounded_bar,
      bar_height = dpi(10),
      bar_color = beautiful.nord3,
      bar_active_color = beautiful.nord15,
      handle_width = dpi(0),
      value = 25,
      widget = wibox.widget.slider,
    },
    id = "sliderbox",
    direction = "east",
    forced_height = dpi(0),
    widget = wibox.container.rotate,
  })

  local icon = wibox.widget({
    {
      markup = helpers.ui.colorize_text("", beautiful.nord15),
      widget = wibox.widget.textbox,
      font = beautiful.font .. "13",
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

  local volume_slider = slider.children[1]
  
  -- Animations!
  local open = animation:new({
    duration = 0.15,
    pos = 0,
    target = 75,
    easing = animation.easing.linear,
    reset_on_stop = true,
    update = function(self, pos)
      slider.forced_height = dpi(pos)
    end,
  })

  local close = animation:new({
    duration = 0.15,
    pos = 75,
    target = 0,
    easing = animation.easing.linear,
    reset_on_stop = true,
    update = function(self, pos)
      slider.forced_height = dpi(pos)
    end,
  })

  -- Animations!!!
  local bar_animation = animation:new({
    duration = 0.1,
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

  widget:connect_signal("mouse::release", function()

  end)
  
  -- Update volume based on slider value 
  volume_slider:connect_signal("property::value", function()
    local volume_level = volume_slider:get_value()
    awful.spawn("pamixer --set-volume " .. volume_level, false)
   
    -- ???
    -- Update volume osd
  	-- awesome.emit_signal("module::volume_osd", volume_level)
  end)
  
  -- WIP: update slider value based on volume

  return widget
end
