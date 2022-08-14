
-- █▀▄ █▀█ █▀▀ ▄▀█ █▀▄▀█ █▀
-- █▄▀ █▀▄ ██▄ █▀█ █░▀░█ ▄█

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local gfs = require ("gears.filesystem")
local dir = gfs.get_configuration_dir() .. "ui/dash/dreams/"

local function create_imagebox(path, width, height)
  return wibox.widget({
    image = path,
    resize = true,
    forced_height = dpi(height),
    clip_shape = gears.shape.rect,
    widget = wibox.widget.imagebox,
  })
end

local text = wibox.widget({
  markup = helpers.ui.colorize_text("Remember what you're working for.", beautiful.xforeground),
  font = beautiful.header_font_name .. "Light 40",
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  {
    --text,
    {
      create_imagebox(dir .. "hawaii.jpg", 300, 300),
      create_imagebox(dir .. "room.jpg", 300, 400),
      create_imagebox(dir .. "van.jpg", 300, 300),
      create_imagebox(dir .. "battlestation.jpg", 300, 300),
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    create_imagebox(dir .. "battlewagon.jpg", 300, 430),
    align = "center",
    valign = "center",
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(20),
  widget = wibox.container.margin,
})

return widget
