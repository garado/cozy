
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s) 

  s.dash = awful.popup({
    type = "dock",
    screen = s,
    ontop = true,
    visible = false,
    placement = function(w)
    end,
    widget = {
    } -- end widget
  })

  -- toggle visibility
  awesome.connect_signal("dash::toggle", function(scr)
    s.central_panel.visible = not s.central_panel.visible
  end)
end
