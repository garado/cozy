
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

-- Widgets
local linegraph = require("frontend.widget.linegraph")

-- Modules
local balance = require(... .. ".balance")
local budget  = require(... .. ".budget")

local content = wibox.widget({
  {
    balance,
    widget = wibox.container.place,
  },
  budget,
  layout = wibox.layout.fixed.vertical,
})

-------------------------

local header = ui.textbox({
  text = "Ledger",
  align = "left",
  font = beautiful.font_light_xl,
})

local container = wibox.widget({
  {
    header,
    nil,
    layout = wibox.layout.align.horizontal,
  },
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
