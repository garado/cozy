
-- █▀ █▄█ █▀ █▀▀ █▀█ █▄░█ █▀▀
-- ▄█ ░█░ ▄█ █▄▄ █▄█ █░▀█ █▀░

-- Configuration options for window management stuff.

require(... .. ".autostart")
require(... .. ".keys")
require(... .. ".layout")
require(... .. ".ruled")
require(... .. ".tags")
require(... .. ".restore")

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

require("awful.autofocus")

-- Enable sloppy focus so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Apply wallpaper
awful.screen.connect_for_each_screen(function(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, false, nil)
  end
end)

-- Only show border when there's more than 1 window on screen
screen.connect_signal("arrange", function(s)
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if only_one and not c.floating or c.maximized or c.fullscreen then
      c.border_width = 0
    else
      c.border_width = beautiful.border_width
    end
  end
end)
