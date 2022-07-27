local awful = require("awful")

local bar = require(... .. ".bar")

-- Put bar on each screen
awful.screen.connect_for_each_screen(function(s)
  bar(s) 
end)
