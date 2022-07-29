
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
  s.profile = require("ui.dash.main.profile")
  --s.links = require("ui.dash.main.links")
  s.pepedoro = require("ui.dash.main.pepedoro")
  s.stats = require("ui.dash.main.stats")(s)
  s.events = require("ui.dash.main.events")
  s.tasks = require("ui.dash.main.tasks")
  
  widget = {
    {
      {
        s.profile,
        s.stats,
        s.pepedoro,
        -- forced_width = dpi(300),
        layout = wibox.layout.fixed.vertical,
      },
      {
        s.events,
        s.tasks,
        forced_width = dpi(650),
        layout = wibox.layout.fixed.vertical,
      },
      {
        s.links,
        forced_width = dpi(100),
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    bg = beautiful.background_dark,
    widget = wibox.container.background,
  } -- end widget
  return widget
end

