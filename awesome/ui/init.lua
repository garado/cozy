
-- █░█ █    █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀ 
-- █▄█ █    ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█ 

-- Here Cozy's UI elements are added to the screen.

require(... .. ".notifications")

local awful  = require("awful")
local config = require("cozyconf") or {}

if config.tabletmode then
  require(... .. ".touchscreen")
end

local bar
if config.barstyle == "vertical" or not config.barstyle then
  bar = require(... .. ".vbar")
elseif config.barstyle == "horizontal" then
  bar = require(... .. ".hbar")
end

local tswitch   = require(... .. ".themeswitcher")

awful.screen.connect_for_each_screen(function(s)
  tswitch()
  bar(s)
end)
