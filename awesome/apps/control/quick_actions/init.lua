
-- █▀█ █░█ █ █▀▀ █▄▀    ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- ▀▀█ █▄█ █ █▄▄ █░█    █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local keynav  = require("modules.keynav")
local control = require("core.cozy.control")

local calc, nav_calc = require(... .. ".calculator")()
local rotate, nav_rotate = require(... .. ".rotate")()
local nshift, nav_nshift = require(... .. ".nightshift")()
local cons, nav_cons = require(... .. ".conservation")()

local nav_qactions = keynav.area({
  name = "qactions",
  circular  = true,
  is_grid   = true,
  grid_cols = 5,
  grid_rows = 2,
  children = {
    nav_calc,
    nav_rotate,
    nav_nshift,
    nav_cons,
  },
})

local header = wibox.widget({
  markup = ui.colorize("QUICK ACTIONS", beautiful.fg_0),
  font   = beautiful.font_reg_xs,
  align  = "center",
  widget = wibox.widget.textbox,
  -------
  set_header = function(self, text)
    text = string.upper(text)
    local mkup = ui.colorize(text, beautiful.fg_0)
    self:set_markup_silently(mkup)
  end
})

local qactions = wibox.widget({
  {
    header,
    {
      calc,
      rotate,
      nshift,
      cons,
      forced_num_rows = 2,
      forced_num_cols = 5,
      homogeneous = true,
      spacing = dpi(15),
      layout  = wibox.layout.grid,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

control:connect_signal("qaction::selected", function(_, name)
  header:set_header(name)
end)

return function()
  return qactions, nav_qactions
end
