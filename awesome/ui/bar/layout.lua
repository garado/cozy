
-- █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ 
-- █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ 

-- Available layouts:
-- mstab

local beautiful = require("beautiful")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local wibox = require("wibox")
local awful = require("awful")

return function()
  local layout = awful.widget.layoutbox {
    buttons = {
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
      awful.button({ }, 5, function () awful.layout.inc(-1) end),
    }
  }
  layout = wibox.container.margin(layout, 9, 9, 9)
  return layout
end
