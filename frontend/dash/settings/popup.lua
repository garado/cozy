
-- █▀▀ █▀█ █░░ █▀█ █▀█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- A simple tool for modifying colors in a palette

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dash  = require("backend.cozy.dash")
local clib  = require("modules.color")

local function gen_slider(label)
  local _slider = wibox.widget({
    value = 50,
    minimum = 0,
    maximum = label == "H" and 360 or 100,
    forced_height = dpi(12),
    handle_height = dpi(12),
    handle_margins = dpi(0),
    bar_margins  = dpi(0),
    forced_width = dpi(100),
    handle_shape = gears.shape.circle,
    handle_color = beautiful.fg,
    bar_shape = ui.rrect(),
    bar_color = beautiful.neutral[500],
    widget = wibox.widget.slider,
  })

  local slider = wibox.widget({
    ui.textbox({
      text  = label,
      align = "center",
    }),
    {
      _slider,
      widget = wibox.container.place,
    },
    ui.textbox({
      text  = "255",
      align = "right",
    }),
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
    -----
    update_value = function(self, v)
      _slider.value = v
    end
  })

  _slider:connect_signal("property::value", function(_, new_value)
    slider.children[3]:new_text(new_value)
  end)

  return slider
end

local hue = gen_slider("H")
local sat = gen_slider("S")
local light = gen_slider("L")

local widget = {
  ui.textbox({
    text = "Edit color",
    font = beautiful.font_bold_s,
  }),
  hue,
  sat,
  light,
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

awesome.connect_signal("colorpopup::toggle", function(color)
  cpopup.visible = not cpopup.visible
  if cpopup.visible then
    local c = clib.color { hex = color }
    hue:update_value(c.h)
    sat:update_value(c.s)
    light:update_value(c.l)
  end
end)

dash:connect_signal("setstate::close", function()
  cpopup.visible = false
end)

dash:connect_signal("tab::set", function()
  cpopup.visible = false
end)
