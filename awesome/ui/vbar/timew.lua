
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- Displays clock icon if Timewarrior session is active

local beautiful = require("beautiful")
local wibox = require("wibox")
local time  = require("core.system.time")
local awful = require("awful")

local colorize = require("helpers.ui").colorize_text

local icon = wibox.widget({
  visible = false,
  markup  = colorize("", beautiful.wibar_fg),
  font    = beautiful.font_reg_xs,
  widget  = wibox.widget.textbox,
})

time:connect_signal("tracking_active", function()
  icon.visible = true
end)

time:connect_signal("tracking_inactive", function()
  icon.visible = false
end)

local widget = wibox.widget({
  icon,
  widget = wibox.container.place,
})

return widget
