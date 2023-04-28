
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local _accounts = require(... .. ".accounts")()
local budget    = require(... .. ".budget")

local accounts = wibox.widget({
  _accounts[1],
  _accounts[2],
  spacing = dpi(15),
  layout = wibox.layout.fixed.horizontal,
})

local content = wibox.widget({
  {
    accounts,
    widget = wibox.container.place,
  },
  budget,
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
})

-------------------------

local header = ui.textbox({
  text = "Ledger",
  align = "left",
  font = beautiful.font_light_xl,
})

local actions = {
  ui.button({
    text = "Update",
    font = beautiful.font_med_s,
    color = beautiful.primary[700],
    bg = beautiful.primary[200],
    bg_mo = beautiful.primary[300],
    border_color = beautiful.primary[600],
    forced_height = dpi(10),
    border_width = dpi(1),
  }),
  ui.button({
    text = "Edit",
    font = beautiful.font_med_s,
    color = beautiful.primary[700],
    bg = beautiful.primary[200],
    bg_mo = beautiful.primary[300],
    border_color = beautiful.primary[600],
    border_width = dpi(1),
    forced_height = dpi(10),
  }),
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
}

local container = wibox.widget({
  {
    header,
    nil,
    actions,
    layout = wibox.layout.align.horizontal,
  },
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.09, 0.91)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
