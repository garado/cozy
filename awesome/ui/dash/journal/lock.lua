
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░    █░░ █▀█ █▀▀ █▄▀ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄    █▄▄ █▄█ █▄▄ █░█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local journal = require("core.system.journal")

local header = wibox.widget({
  markup = colorize(" Log is locked", beautiful.fg),
  font   = beautiful.alt_font_name .. "Regular 50",
  align  = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

local subheader = wibox.widget({
  markup = colorize("Enter passcode to proceed", beautiful.fg),
  font   = beautiful.base_med_font,
  align  = "center",
  valign = "center",
  forced_height = dpi(50),
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  header,
  subheader,
  layout = wibox.layout.fixed.vertical,
})

return widget
