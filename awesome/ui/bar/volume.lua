
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
local tonumber = tonumber
local string = string

local slider = wibox.widget({
  {
    bar_shape = gears.shape.rounded_bar,
    bar_height = dpi(10),
    bar_color = beautiful.wibar_slider_bg,
    bar_active_color = beautiful.wibar_vol_fg,
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
    markup = helpers.ui.colorize_text("", beautiful.wibar_vol_fg),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "13",
    align = "center",
    valign = "center",
  },
  widget = wibox.container.margin,
})

local widget = wibox.widget({
  slider,
  icon,
  layout = wibox.layout.align.vertical,
})


-- Pressing the volume icon will toggle mute
icon:connect_signal("button::press", function()
  awful.spawn("pamixer --toggle-mute", false)
  awesome.emit_signal("module::volume")
end)

-- Update volume based on slider value 
local volume_slider = slider.children[1]
volume_slider:connect_signal("property::value", function()
  local volume_level = volume_slider:get_value()
  awful.spawn("pamixer --set-volume " .. volume_level, false)
end)

-- updates volume icon based on volume level :)
vol_icon = icon.children[1]
awesome.connect_signal("module::volume", function()
  awful.spawn.easy_async_with_shell("pamixer --get-volume-human",
    function(stdout)
      local out = string.gsub(stdout, '%W','')
      local outnum = tonumber(out)
      if out == "muted" or outnum < 6 then
        vol_icon:set_markup(helpers.ui.colorize_text("婢", beautiful.wibar_vol_fg))
      elseif outnum < 33 then
        vol_icon:set_markup(helpers.ui.colorize_text("奄", beautiful.wibar_vol_fg))
      elseif outnum < 66 then
        vol_icon:set_markup(helpers.ui.colorize_text("奔", beautiful.wibar_vol_fg))
      else
        vol_icon:set_markup(helpers.ui.colorize_text("墳", beautiful.wibar_vol_fg))
      end
    end
  )
end)

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
