
-- ░░█ █░█ █▀▄▀█ █▀█ 
-- █▄█ █▄█ █░▀░█ █▀▀ 

-- Jump-to-date popup.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash  = require("backend.cozy.dash")
local calwidget = require("frontend.widget.calendar")

local widget = wibox.widget({
  {
    ui.textbox({
      text  = "Jump to date",
      align = "center",
      font  = beautiful.font_reg_l,
    }),
    {
      calwidget,
      widget = wibox.container.place,
    },
    spacing = dpi(15),
    layout  = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.background,
})

local caljump = awful.popup({
  type = "splash",
  minimum_height = dpi(200),
  minimum_width  = dpi(370),
  maximum_width  = dpi(370),
  placement = awful.placement.centered,
  bg = beautiful.neutral[700],
  ontop   = true,
  visible = false,
  widget  = wibox.widget({
    widget,
    margins = dpi(15),
    widget  = wibox.container.margin,
  })
})

dash:connect_signal("caljump::show", function(_, x, y)
  caljump.visible = true
end)

dash:connect_signal("caljump::hide", function()
  caljump.visible = false
end)

dash:connect_signal("caljump::toggle", function(_)
  caljump.visible = not caljump.visible
end)

return function() return caljump end
