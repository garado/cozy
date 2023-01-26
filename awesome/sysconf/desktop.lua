-- █▀▄ █▀▀ █▀ █▄▀ ▀█▀ █▀█ █▀█ 
-- █▄▀ ██▄ ▄█ █░█ ░█░ █▄█ █▀▀ 

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

require("awful.autofocus")

-- i dont understand this
client.connect_signal("request::manage", function(c)
	--- Add missing icon to client
	if not c.icon then
		local icon = gears.surface(beautiful.theme_assets.awesome_icon(24, beautiful.xcolor8, beautiful.xbackground))
		c.icon = icon._native
		icon:finish()
	end

	--- Set the windows at the slave,
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		--- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Enable sloppy focus so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Wallpaper
awful.screen.connect_for_each_screen(function(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, false, nil)
  end
end)
