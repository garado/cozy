
-- █▄░█ █▀█ ▀█▀ █ █▀▀    ▀█▀ █▀█ █▀▀ █▀▀ █░░ █▀▀ 
-- █░▀█ █▄█ ░█░ █ █▀░    ░█░ █▄█ █▄█ █▄█ █▄▄ ██▄ 

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local helpers = require("helpers")
local naughty = require("naughty")

local notif_enabled_icon = ""
local notif_disabled_icon = ""
local notif_icon_color = beautiful.wibar_notif_fg
local notif_button = wibox.widget({
  align = "center",
  valign = "center",
  font = beautiful.font_name .. "15",
  widget = wibox.widget.textbox,
})

local function toggle_notif()
  local markup
  if naughty.suspended then
    markup = helpers.ui.colorize_text(notif_enabled_icon, notif_icon_color)
  elseif not naughty.suspended then
    markup = helpers.ui.colorize_text(notif_disabled_icon, notif_icon_color)
  end
  notif_button:set_markup_silently(markup)
  naughty.suspended = not naughty.suspended
end

notif_button:connect_signal("button::release", toggle_notif)

-- set initial state
-- this doesn't work when awesome is restarted for some reason
-- so default to enabled for now
-- local markup
-- if naughty.suspended == true then
-- else
--   markup = helpers.ui.colorize_text(notif_disabled_icon, notif_icon_color)
-- end
local markup = helpers.ui.colorize_text(notif_enabled_icon, notif_icon_color)
notif_button:set_markup_silently(markup)

return notif_button
