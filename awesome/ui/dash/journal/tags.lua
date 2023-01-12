
-- ▀█▀ ▄▀█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█ 

local wibox   = require("wibox")
local gears   = require("gears")
local area    = require("modules.keynav.area")
local naventry    = require("modules.keynav.navitem").Textbox
local beautiful   = require("beautiful")
local colorize    = require("helpers.ui").colorize_text
local xresources  = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local time    = require("core.system.time")

local widget = wibox.widget({
  wibox.widget({
    markup = colorize("Tags", beautiful.fg),
    align  = "center",
    valign = "center",
    font   = beautiful.alt_large_font,
    widget = wibox.widget.textbox,
  }),
  spacing = dpi(5),
  layout  = wibox.layout.fixed.horizontal,
})

return widget
