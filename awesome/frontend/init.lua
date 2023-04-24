
-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

require(... .. ".notifications")

local awful = require("awful")

local bar = require(... .. ".vbar")

awful.screen.connect_for_each_screen(function(s)
  bar(s)
end)
