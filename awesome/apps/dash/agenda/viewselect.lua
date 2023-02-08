
-- █░█ █ █▀▀ █░█░█    █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀ 
-- ▀▄▀ █ ██▄ ▀▄▀▄▀    ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░ 

-- A few indicators that show the current view

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local keynav = require("modules.keynav")
local gears = require("gears")
local ui    = require("helpers.ui")
local dash  = require("core.cozy.dash")

local overview, weekview

-- For overview tab
overview = wibox.widget({
  {
    {
      id     = "textbox",
      markup = ui.colorize("Overview", beautiful.fg_0),
      align  = "center",
      font   = beautiful.font_reg_s,
      widget = wibox.widget.textbox,
    },
    margins = dpi(10),
    widget  = wibox.container.margin,
  },
  bg     = beautiful.bg_2,
  shape  = gears.shape.rounded_rect,
  widget = wibox.container.background,
  ------
  select = function(self)
    self.children[1].children[1].font = beautiful.font_reg_s
    self.bg = beautiful.bg_2
  end,
  deselect = function(self)
    self.children[1].children[1].font = beautiful.font_light_s
    self.bg = beautiful.bg_0
  end,
})

local nav_overview = keynav.navitem.background({
  widget  = overview,
  bg_on   = beautiful.bg_2,
  bg_off  = beautiful.bg_0,
  release = function(self)
    dash:emit_signal("agenda::view_selected", "overview")
    self.widget:select()
    weekview:deselect()
  end
})

-- For overview tab
weekview = wibox.widget({
  {
    {
      id     = "textbox",
      markup = ui.colorize("Weekview", beautiful.fg_0),
      align  = "center",
      font   = beautiful.font_light_s,
      widget = wibox.widget.textbox,
    },
    margins = dpi(10),
    widget  = wibox.container.margin,
  },
  shape  = gears.shape.rounded_rect,
  widget = wibox.container.background,
  ------
  select = function(self)
    self.children[1].children[1].font = beautiful.font_reg_s
    self.bg = beautiful.bg_2
  end,
  deselect = function(self)
    self.children[1].children[1].font = beautiful.font_light_s
    self.bg = beautiful.bg_0
  end,
})

local nav_weekview = keynav.navitem.background({
  widget  = weekview,
  bg_off  = beautiful.bg_0,
  release = function(self)
    dash:emit_signal("agenda::view_selected", "weekview")
    self.widget:select()
    overview:deselect()
  end
})

-- Assemble final UI
local cont = wibox.widget({
  {
    overview,
    weekview,
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local nav_viewselect = keynav.area({
  name = "viewselect",
  circular = true,
  children = {
    nav_overview,
    nav_weekview,
  }
})

return function()
  return cont, nav_viewselect
end
