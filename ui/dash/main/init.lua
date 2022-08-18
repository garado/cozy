
-- █▀▄ ▄▀█ █▀ █░█ ▀   █▀▄▀█ ▄▀█ █ █▄░█
-- █▄▀ █▀█ ▄█ █▀█ ▄   █░▀░█ █▀█ █ █░▀█

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Import elements of the dash
local profile = require("ui.dash.main.profile")
local links = require("ui.dash.main.links")
local pomodoro = require("ui.dash.main.pomodoro")
local events = require("ui.dash.main.events")
local tasks = require("ui.dash.main.tasks")
local music = require("ui.dash.main.music_player")
--local fetch = require("ui.dash.main.fetch")
local habit = require("ui.dash.main.habit")
local monthly_spending = require("ui.dash.main.monthly_spending")
local timedate = require("ui.dash.main.timedate")
local goals = require("ui.dash.main.goals")
local naughty = require("naughty")

-- width of widgets is set here
-- height of widgets is set within the widget.lua
local widget = wibox.widget({
  {
    {
      profile,
      timedate,
      goals,
      music,
      --fetch,
      forced_width = dpi(350),
      expand = true,
      layout = wibox.layout.fixed.vertical,
    },
    {
      events,
      tasks,
      monthly_spending,
      forced_width = dpi(550),
      layout = wibox.layout.fixed.vertical,
    },
    {
      --links,
      pomodoro,
      habit,
      forced_width = dpi(400),
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
  },
  bg = beautiful.dash_bg,
  widget = wibox.container.background,
}) -- end widget

return widget
