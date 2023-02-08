
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local navbase = require("modules.keynav.navitem").Base
local navbg = require("modules.keynav.navitem").Background
local gears = require("gears")
local agenda = require("core.system.cal")
local ui = require("helpers.ui")

local viewselect, nav_viewselect = require("apps.dash.agenda.viewselect")()

local htext = os.date("%B %m")
local ytext = os.date("%Y")

-- Top part of the calendar
local header = wibox.widget({
  {
    {
      {
        markup = ui.colorize(htext, beautiful.fg_0),
        font   = beautiful.font_reg_xl,
        widget = wibox.widget.textbox,
      },
      {
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
  top    = dpi(20),
  left   = dpi(30),
  right  = dpi(30),
  widget = wibox.container.margin,
})

return function()
  return header, nav_viewselect
end
