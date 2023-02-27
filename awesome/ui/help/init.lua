
-- █░█ █▀▀ █░░ █▀█ 
-- █▀█ ██▄ █▄▄ █▀▀ 

-- A custom help menu (because I really don't like the default.)

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- local help = awful.popup({
--   screen = s,
--   type = "dock",
--   minimum_width  = s.geometry.width,
--   maximum_width  = s.geometry.width,
--   minimum_height = dpi(35),
--   maximum_height = dpi(35),
--   placement = awful.placement.top,
--   -- widget = 
-- })
