
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

awful.screen.connect_for_each_screen(require(... .. ".bar." .. conf.bar_style))
