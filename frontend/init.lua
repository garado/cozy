
-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

require(... .. ".notifications")

local awful = require("awful")

local ts   = require(... .. ".themeswitch")
local bar  = require(... .. ".vbar")
local dash = require(... .. ".dash")
local navtest = require(... .. ".navtest")

local calpopup = require("frontend.dash.calendar.popup")
local caljump = require("frontend.dash.calendar.jump-popup")

awful.screen.connect_for_each_screen(function(s)
  ts(s)
  bar(s)
  dash(s)
  navtest(s)
  calpopup()
  caljump()
end)
