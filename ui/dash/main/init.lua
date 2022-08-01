
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
  --links = require("ui.dash.main.links")
  pepedoro = require("ui.dash.main.pepedoro")
  stats = require("ui.dash.main.stats")
  events = require("ui.dash.main.events")
  tasks = require("ui.dash.main.tasks")
  music = require("ui.dash.main.music_player")
 
  widget = {
    {
      {
        profile,
        pepedoro,
        music,
        forced_width = dpi(350),
        layout = wibox.layout.fixed.vertical,
      },
      {
        events,
        tasks,
        forced_width = dpi(600),
        layout = wibox.layout.fixed.vertical,
      },
      {
        stats,
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

