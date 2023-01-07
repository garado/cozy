
-- █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize  = require("helpers.ui").colorize_text
local weather   = require("core.system.weather")

local widget = wibox.widget({
  markup = colorize("Weather", beautiful.fg),
  align  = "center",
  valign = "center",
  font   = beautiful.alt_large_font,
  widget = wibox.widget.textbox,
})

return widget
