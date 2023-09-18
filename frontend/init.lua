
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
require(... .. ".kitty")
require("frontend.dash.calendar.week.details")

local path = ...
awful.screen.connect_for_each_screen(function(s)
  require(path .. ".bar." .. conf.bar_style)(s)
end)
