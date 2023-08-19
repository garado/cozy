
-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

require(... .. ".notifications")

local awful = require("awful")
local conf  = require("cozyconf")
local ts    = require(... .. ".themeswitch")
local dash  = require(... .. ".dash")
local ctrl  = require(... .. ".control")

local caldetails = require("frontend.dash.calendar.week.details")

local bar
if conf.bar_style == "horizontal" then
  bar = require(... .. ".bar.hbar")
else
  bar = require(... .. ".bar.vbar")
end

awful.screen.connect_for_each_screen(function(s)
  ts(s)
  bar(s)
  dash(s)
  ctrl(s)

  caldetails()
end)
