
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local user_vars = require("user_variables")

local image = beautiful.pfp

local profile = wibox.widget({
  image = image,
  resize = true,
  valign = "center",
  align = "center",
  forced_height = dpi(40),
  forced_width = dpi(40),
  clip_shape = gears.shape.circle,
  widget = wibox.widget.imagebox,
})

local name = wibox.widget({
  markup = helpers.ui.colorize_text(user_vars.display_name, beautiful.fg),
  align = "left",
  valign = "center",
  widget = wibox.widget.textbox,
})

local host = wibox.widget({
  widget = wibox.widget.textbox,
  align = "left",
  valign = "center",
  font = beautiful.font .. "10",
})

awful.spawn.easy_async_with_shell("hostname", function(stdout)
  local text = helpers.ui.colorize_text("@" .. stdout, beautiful.ctrl_host)
  host:set_markup_silently(text)
end)

return wibox.widget({
  {
    profile,
    {
      name,
      host,
      spacing = dpi(3),
      layout = wibox.layout.flex.vertical,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})
