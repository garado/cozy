
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
local habit_overview = require("ui.dash.habit.weekly_overview")

local habit_tab_header = wibox.widget({
})

-- Assemble
return wibox.widget({
  habit_overview,
  layout = wibox.layout.fixed.horizontal,
})
