
-- █░█ █ █▀▀ █░█░█ ▀    █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀ 
-- ▀▄▀ █ ██▄ ▀▄▀▄▀ ▄    ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░ 

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears   = require("gears")
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local buscore = require("core.web.bus")
local core    = require("helpers.core")
local keynav  = require("modules.keynav")
local config  = require("cozyconf")

local SELECT = 1
local TRACK  = 2
local deselect_options

-- Layoutbox that destination options will be appended to
local options = wibox.widget({
  spacing = dpi(7),
  layout  = wibox.layout.fixed.vertical,
})

local nav_options = keynav.area({
  name = "options"
})

-- Create destination options
for i = 1, #config.bus do
  local checkbox = wibox.widget({
    border_width  = 1.5,
    forced_height = dpi(15),
    forced_width  = dpi(15),
    check_shape   = gears.shape.circle,
    check_color   = beautiful.fg_0,
    color     = beautiful.fg_0,
    shape     = gears.shape.circle,
    paddings  = dpi(3),
    checked   = false,
    widget    = wibox.widget.checkbox,
  })

  local text = config.bus[i].from .."  ".. config.bus[i].to
  local label = wibox.widget({
    markup = ui.colorize(text, beautiful.fg_0),
    widget = wibox.widget.textbox,
  })

  local option = wibox.widget({
    {
      checkbox,
      widget = wibox.container.place,
    },
    label,
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
    -----
    get_checkbox = function(self)
      return self.children[1].widget
    end
  })

  local nav_option = keynav.navitem.checkbox({
    widget  = checkbox,
    data    = config.bus[i],
    deselect_bg = beautiful.dash_widget_bg,
    check_deselect_bg = beautiful.fg_0,
    release = function(self)
      deselect_options()
      self.widget.checked = true
      buscore.route_info = self.data
    end
  })

  options:add(option)
  nav_options:add(nav_option)
end

function deselect_options()
  for i = 1, #options.children do
    options.children[i]:get_checkbox().checked = false
  end
end

local header = wibox.widget({
  markup = ui.colorize("Where's the damn bus?", beautiful.fg_0),
  font   = beautiful.genfont("a", "r", "m"),
  align  = "center",
  widget = wibox.widget.textbox,
})

local subheader = wibox.widget({
  markup = ui.colorize("Select route to begin", beautiful.fg_0),
  align  = "center",
  widget = wibox.widget.textbox,
})

local find_button = ui.simple_button({ text = "Find the damn bus",
  bg   = beautiful.bg_2,
  margins = {
    left   = dpi(15),
    right  = dpi(15),
    top    = dpi(10),
    bottom = dpi(10),
  }
})

local nav_find_button = keynav.navitem.background({
  widget  = find_button:get_bg_wibox(),
  bg_off  = beautiful.bg_2,
  bg_on   = beautiful.bg_4,
  release = function()
    buscore:emit_signal("view::switch", TRACK)
    buscore:emit_signal("tracking::start")
  end,
})

-----

local view_select = wibox.widget({
  header,
  subheader,
  options,
  find_button,
  spacing = dpi(20),
  layout  = wibox.layout.fixed.vertical,
})

local nav_view_select = keynav.area({
  name = "bus_select",
  children = {
    nav_options,
    nav_find_button,
  },
})

return function()
  return view_select, nav_view_select
end
