require(... .. ".notifications")

local config = require("config")

local bar
if config.barstyle == "vertical" then
  bar = require(... .. ".vbar")
elseif config.barstyle == "horizontal" then
  bar = require(... .. ".hbar")
end

local dash      = require(... .. ".dash")
local control   = require(... .. ".control")
local tswitch   = require(... .. ".themeswitcher")
local lock      = require(... .. ".lockscreen")

local awful = require("awful")

awful.screen.connect_for_each_screen(function(s)
  if config.lock.enable_lockscreen_on_start then
    lock(s)
  end
  dash(s)
  control(s)
  tswitch()
  bar(s)
end)
