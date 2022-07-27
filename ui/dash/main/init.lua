
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
  s.profile = require("ui.dash.main.profile")(s)
  s.links = require("ui.dash.main.links")(s)
  s.pepedoro = require("ui.dash.main.pepedoro")(s)
  s.stats = require("ui.dash.main.stats")(s)
  
  widget = {
    {
      {
        s.links,
        layout = wibox.layout.flex.vertical,
      },
      {
        s.profile,
        s.stats,
        layout = wibox.layout.flex.vertical,
      },
      {
        layout = wibox.layout.flex.vertical,
      },
      {
        s.pepedoro,
        layout = wibox.layout.flex.vertical,
      },
      layout = wibox.layout.flex.horizontal,
    },
    bg = "bf616a",
    widget = wibox.container.background,
  } -- end widget
  return widget
end

