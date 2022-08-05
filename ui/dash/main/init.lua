
-- █▀▄ ▄▀█ █▀ █░█ ▀   █▀▄▀█ ▄▀█ █ █▄░█
-- █▄▀ █▀█ ▄█ █▀█ ▄   █░▀░█ █▀█ █ █░▀█

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s)
  -- WIDGETS --
  profile = require("ui.dash.main.profile")
  links = require("ui.dash.main.links")
  pomodoro = require("ui.dash.main.pomodoro")
  events = require("ui.dash.main.events")
  tasks = require("ui.dash.main.tasks")
  music = require("ui.dash.main.music_player")
  fetch = require("ui.dash.main.fetch")
  habit = require("ui.dash.main.habit")
 
  widget = {
    {
      {
        profile,
        pomodoro,
        music,
        forced_width = dpi(350),
        expand = true,
        layout = wibox.layout.fixed.vertical,
      },
      {
        events,
        tasks,
        forced_width = dpi(550),
        layout = wibox.layout.fixed.vertical,
      },
      {
        fetch,
        habit,
        --links,
        forced_width = dpi(400),
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    bg = beautiful.dash_bg,
    widget = wibox.container.background,
  } -- end widget
  return widget
end

