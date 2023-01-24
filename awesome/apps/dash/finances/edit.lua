
-- █▀▀ █▀▄ █ ▀█▀ 
-- ██▄ █▄▀ █ ░█░ 

-- in the future i will add the ability to edit ledger entries from the command line, perhaps

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local config = require("config")

-- assemble final widget
local widget = wibox.widget({
  helpers.ui.create_dash_widget_header("Transaction History"),
  {
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  layout = wibox.layout.fixed.vertical,
  widget = wibox.container.place,
})

-- return helpers.ui.create_boxed_widget(widget, dpi(0), dpi(900), beautiful.dash_widget_bg)
return function()
end
