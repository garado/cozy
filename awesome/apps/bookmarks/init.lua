
-- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀ █▀ 
-- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█ ▄█ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local awful   = require("awful")
local wibox   = require("wibox")
local bmcore  = require("core.cozy.bookmarks")

local prompt   = require(... .. ".prompt")
local sections = require(... .. ".sections")

local layout = wibox.widget({
  sections,
  nil,
  prompt,
  layout = wibox.layout.align.vertical,
})

local bookmarks = awful.popup({
  minimum_height = dpi(530),
  maximum_height = dpi(530),
  minimum_width = dpi(980),
  maximum_width = dpi(980),
  placement = awful.placement.centered,
  type    = "splash",
  bg      = beautiful.dash_widget_bg,
  ontop   = true,
  visible = false,
  widget  = wibox.widget({
    layout,
    margins = dpi(30),
    widget  = wibox.container.margin,
  }),
})

bmcore:connect_signal("setstate::open", function()
  bookmarks.visible = true
end)

bmcore:connect_signal("setstate::close", function()
  bookmarks.visible = false
end)

return function(_) return bookmarks end
