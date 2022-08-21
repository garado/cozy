require(... .. ".notifications")

local bar = require(... .. ".bar")
local dash = require(... .. ".dash")
local control_center = require(... .. ".control_center")

-- Put bar on each screen
local awful = require("awful")
awful.screen.connect_for_each_screen(function(s)
  bar(s)
  dash(s)
  control_center(s)
end)
