
-- ▀█▀ █▀█ █░█ █▀▀ █░█ █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- ░█░ █▄█ █▄█ █▄▄ █▀█ ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

-- Enable UI elements made specifically for touchscreen devices.

local awful = require("awful")


awful.screen.connect_for_each_screen(function(s)
  require("ui.touchscreen.launcher")()
end)
