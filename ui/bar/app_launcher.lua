
-- █▄▄ ▄▀█ █▀█ ▀   █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local gears = require("gears")
local naughty = require("naughty")

local app_launcher

local function create_launcher_entry(icon, program)
  local widget = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.wibar_bg,
    animate_size = false,
    size = 20,
    on_release = function()
      awful.spawn(program)
      app_launcher.visible = not app_launcher.visible
    end,
  })

  return widget
end

app_launcher = awful.popup({
  widget = {
    {
      {
        create_launcher_entry("", "xournalpp"),
        create_launcher_entry("", "foliate"),
        create_launcher_entry("", "alacritty"),
        create_launcher_entry("", "thunar"),
        create_launcher_entry("", "firefox"),
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.dark_polar_night,
    widget = wibox.container.background,
  },
  x = dpi(50),
  y = dpi(10),
  shape = gears.shape.rounded_rect,
  visible = false,
  ontop = true,
})

local widget = widgets.button.text.normal({
  text = "",
  text_normal_bg = beautiful.xforeground,
  normal_bg = beautiful.dark_polar_night,
  animate_size = false,
  size = 12,
  on_release = function()
    app_launcher.visible = not app_launcher.visible
  end,
})

return widget
