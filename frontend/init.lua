
-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

local awful = require("awful")
local conf = require("cozyconf")

require(... .. ".popups")
require(... .. ".notifications")
require(... .. ".themeswitch")
require(... .. ".dash")
require(... .. ".help")
require(... .. ".control")
require(... .. ".notrofi")
require("frontend.dash.calendar.week.details")

local bar

if conf.bar_style == "horizontal" then
  bar = require(... .. ".bar.hbar")
else
  bar = require(... .. ".bar.vbar")
end

awful.screen.connect_for_each_screen(bar)
