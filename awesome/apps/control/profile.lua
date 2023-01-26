
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local image = beautiful.pfp

local profile = wibox.widget({
  {
    image = image,
    resize = true,
    valign = "center",
    align = "center",
    forced_height = dpi(80),
    forced_width = dpi(80),
    clip_shape = gears.shape.circle,
    widget = wibox.widget.imagebox,
  },
  bg = beautiful.ctrl_pfp_bg,
  shape = gears.shape.circle,
  widget = wibox.container.background,
})

local widget = wibox.widget({
  profile,
  widget = wibox.container.place,
})

return widget
