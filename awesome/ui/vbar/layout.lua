
-- █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ 
-- █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ 

-- Available layouts:
-- mstab

local beautiful = require("beautiful")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

return function()
  local layout = awful.widget.layoutbox {
    buttons = {
      awful.button({ }, 1, function () awful.layout.inc( 1) end),
      awful.button({ }, 3, function () awful.layout.inc(-1) end),
      awful.button({ }, 4, function () awful.layout.inc( 1) end),
      awful.button({ }, 5, function () awful.layout.inc(-1) end),
    }
  }

  -- Recolor layout icon when set
  local tag = awful.screen.focused().selected_tag
  tag:connect_signal("property::selected", function()
    if not layout or #layout.children == 0 then return end
    gears.color.recolor_image(layout.children[1].image, beautiful.main_accent)
  end)

  local fuck = wibox.container.margin(layout, 9, 9, 9)
  return fuck
end
