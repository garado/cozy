require(... .. ".notifications")

local bar = require(... .. ".bar")
local dash = require(... .. ".dash")
local control_center = require(... .. ".control_center")
local switcher = require(... .. ".theme_switcher")
local layoutlist = require(... .. ".layoutlist")
local daily_briefing = require(... .. ".daily_briefing")

-- Put bar on each screen
local awful = require("awful")
awful.screen.connect_for_each_screen(function(s)
  bar(s)
  dash(s)
  control_center()
  switcher()
  layoutlist(s)
  daily_briefing()
end)
