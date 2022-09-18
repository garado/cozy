
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- cpu, ram, disk usage
-- wifi, bluetooth

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gfs = require("gears.filesystem")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local widget = wibox.widget({
  widget = wibox.container.place,
})

return widget
