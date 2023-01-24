local awful = require("awful")
local bookmarks = require(... .. ".bookmarks")

awful.screen.connect_for_each_screen(function(s)
  bookmarks(s)
end)
