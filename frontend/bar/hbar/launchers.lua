
-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ █▀ 
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local button = require("frontend.widget.button")

local function gen_launcher(icon)
  return button({
    text = icon,
    margins = dpi(6),
  })
end

local launchers = wibox.widget({
  gen_launcher("󰂯"),
  gen_launcher("󰖩"),
  gen_launcher("󰕾"),
  layout = wibox.layout.fixed.horizontal,
})

return wibox.widget({
  {
    launchers,
    widget = wibox.container.margin,
  },
  shape = ui.rrect(),
  bg = beautiful.neutral[800],
  widget = wibox.container.background,
})
