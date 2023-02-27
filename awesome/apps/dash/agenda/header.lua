
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local xresources = require("beautiful.xresources")
local beautiful  = require("beautiful")
local wibox = require("wibox")
local dpi   = xresources.apply_dpi
local ui    = require("helpers.ui")

local viewselect, nav_viewselect = require("apps.dash.agenda.viewselect")()

local dtext = os.date("%B %d")
local ytext = os.date("%Y")

local header = wibox.widget({
  {
    {
      { -- Date
        markup = ui.colorize(dtext, beautiful.fg_0),
        font   = beautiful.font_reg_xl,
        widget = wibox.widget.textbox,
      },
      { -- Year
        markup = ui.colorize(ytext, beautiful.fg_2),
        font   = beautiful.font_light_xl,
        widget = wibox.widget.textbox,
      },
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    nil,
    viewselect,
    forced_width = dpi(3000),
    layout  = wibox.layout.align.horizontal,
  },
  top    = dpi(10),
  left   = dpi(30),
  right  = dpi(30),
  widget = wibox.container.margin,
})

return function()
  return header, nav_viewselect
end
