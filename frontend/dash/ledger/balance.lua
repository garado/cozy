
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀ 
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local graph = require("frontend.widget.linegraph")

local g = graph({
  colors = { beautiful.primary[300] }
})

local balance = wibox.widget({
  { -- Top
    ui.textbox({
      text = "Total Balance",
      font = beautiful.font_med_s,
      color = beautiful.neutral[200],
      align = "left",
    }),
    nil,
    {
      {
        ui.textbox({
          text = " 20%",
          font = beautiful.font_bold_s,
          color = beautiful.green[500],
        }),
        top = dpi(3),
        bottom = dpi(3),
        widget = wibox.container.margin,
      },
      forced_width = dpi(80),
      bg = beautiful.green[100],
      shape = ui.rrect(),
      widget = wibox.container.background,
    },
    layout = wibox.layout.align.horizontal,
  },
  ui.textbox({
    text = "$300.00",
    align = "left",
    font = beautiful.font_light_xl,
  }),
  {
    g,
    forced_height = dpi(50),
    forced_width  = dpi(300),
    widget = wibox.container.place,
  },
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

for _ = 1, 10 do
  g:add_data({ math.random() })
end

return ui.dashbox(balance, dpi(450))
