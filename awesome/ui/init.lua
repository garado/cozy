require(... .. ".notifications")

local vbar = require(... .. ".vbar")
local dash = require(... .. ".dash")
local ctrl = require(... .. ".control")
local switcher = require(... .. ".themeswitcher")
local calpopup = require(... .. ".dash.agenda.popup")

local awful = require("awful")

awful.screen.connect_for_each_screen(function(s)
  vbar(s)
  dash(s)
  ctrl(s)
  switcher()
  calpopup()
end)
