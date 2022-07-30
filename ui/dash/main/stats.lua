
-- █▀▄ ▄▀█ █▀ █░█ ▀   █▀ ▀█▀ ▄▀█ ▀█▀ █▀
-- █▄▀ █▀█ ▄█ █▀█ ▄   ▄█ ░█░ █▀█ ░█░ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local gears = require("gears")

-- stats:
-- battery volume brightness cpu ram storage temp

-- Get statistics



local function create_stat(icon, val, fg)
  local widget = wibox.widget({ 
    {
      {
        markup = helpers.ui.colorize_text(icon, fg),
        widget = wibox.widget.textbox,
        font = "Roboto Mono Nerd Font Regular 15",
      },
      {
          value = val,
          max_value = 100,
          forced_height = dpi(20),
          forced_width = dpi(200),
          border_width = 0,
          color = fg,
          background_color = beautiful.nord1,
          border_color = fg,
          shape = gears.shape.rounded_bar,
          bar_shape = gears.shape.rounded_bar,
          widget = wibox.widget.progressbar,
      },
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })
  
  return widget
end

local function widget()
  local widget = wibox.widget({
    {
      create_stat("", 50, beautiful.nord11),
      create_stat("", 50, beautiful.nord12),
      create_stat("", 20, beautiful.nord13),
      create_stat("זּ", 37, beautiful.nord14),
      create_stat("盛", 26, beautiful.nord15),
      create_stat("", 50, beautiful.nord9),
      layout = wibox.layout.flex.vertical,
    },
    margins = dpi(1),
    widget = wibox.container.margin,
  })
  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(200), dpi(250), beautiful.dash_widget_bg)
