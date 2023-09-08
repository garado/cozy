
-- █▀▄ █▀▀ █▀ █▄▀ ▀█▀ █▀█ █▀█ 
-- █▄▀ ██▄ ▄█ █░█ ░█░ █▄█ █▀▀ 

local ui = require("utils.ui")
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
