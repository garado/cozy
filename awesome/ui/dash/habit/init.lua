
-- █░█ ▄▀█ █▄▄ █ ▀█▀   █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▀█ █▀█ █▄█ █ ░█░   █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local widgets = require("ui.widgets")
local os = os

-- Import

local habit_tab_header = wibox.widget({
})

-- Assemble
return wibox.widget({
  layout = wibox.layout.fixed.horizontal,
})
