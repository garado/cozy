
-- █▀▀ █▀█ █░░ █▀█ █▀█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- A simple tool for modifying colors in a palette

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash  = require("backend.state.dash")

local function gen_slider(label)
  local slider = wibox.widget({
    ui.textbox({
      text  = label,
      align = "center",
    }),
    {
      value = 50,
      minimum = 0,
      maximum = 255,
      forced_height = dpi(5),
      forced_width = dpi(100),
      handle_width = dpi(15),
      handle_color = beautiful.fg,
      bar_color = beautiful.neutral[500],
      widget = wibox.widget.slider,
    },
    ui.textbox({
      text  = "255",
      align = "right",
    }),
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
    -------
  })

  slider.children[2]:connect_signal("property::value", function(_, new_value)
    slider.children[3]:new_text(new_value)
  end)

  return slider
end

local widget = {
  gen_slider("H"),
  gen_slider("S"),
  gen_slider("L"),
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
}

local cpopup = awful.popup({
  type = "splash",
  minimum_height = dpi(300),
  maximum_height = dpi(300),
  minimum_width  = dpi(200),
  maximum_width  = dpi(200),
  bg = beautiful.neutral[800],
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = ui.place(widget, { margins = dpi(10) }),
})

awesome.connect_signal("colorpopup::toggle", function()
  cpopup.visible = not cpopup.visible
end)

dash:connect_signal("setstate::close", function()
  cpopup.visible = false
end)
