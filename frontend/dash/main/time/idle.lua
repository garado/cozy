
-- █ █▀▄ █░░ █▀▀    █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- █ █▄▀ █▄▄ ██▄    ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local dash  = require("backend.cozy.dash")

local focus_time_today = ui.textbox({
  text  = "3h 45m",
  align = "center",
  font  = beautiful.font_reg_xxl,
})

local start = btn({
  text  = "Start a new session",
  align = "center",
  bg    = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
  func  = function()
    dash:emit_signal("main::time::changestate", "select")
  end
})

local widget = wibox.widget({
  ui.textbox({
    text = "You've focused for",
    align = "center",
    color = beautiful.neutral[400],
  }),
  focus_time_today,
  ui.textbox({
    text = "today.",
    align = "center",
    color = beautiful.neutral[400],
  }),
  ui.vpad(dpi(5)),
  start,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

widget.keys = {
  ["Return"] = function() dash:emit_signal("main::time::changestate", "select") end
}

return widget
