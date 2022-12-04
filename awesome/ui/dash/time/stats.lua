
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 
-- Displays stats for the currently selected month and week.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local area = require("modules.keynav.area")
local gears = require("gears")

local helpers = require("helpers")
local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")

return function(data)
  local stats_cont = wibox.widget({
    text = "stats",
    widget = wibox.widget.textbox,
  })

  return box(stats_cont, dpi(300), dpi(500), beautiful.dash_widget_bg)
end
