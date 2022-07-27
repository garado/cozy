local awful = require("awful")

local bar = require(... .. ".bar")
local dash = require(... .. ".dash")

-- Put bar on each screen
awful.screen.connect_for_each_screen(function(s)
  bar(s)
  dash(s)
end)
