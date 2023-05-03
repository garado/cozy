
-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

require(... .. ".notifications")

local awful = require("awful")

local bar = require(... .. ".vbar")
local dash = require(... .. ".dash")

awful.screen.connect_for_each_screen(function(s)
  bar(s)
  dash(s)
end)
