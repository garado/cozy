
-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ ░ █░░ █░█ ▄▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ ▄ █▄▄ █▄█ █▀█ 

local wibox = require("wibox")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bmcore   = require("core.cozy.bookmarks")
local keynav   = require("modules.keynav")
local colorize = require("helpers.ui").colorize_text

local nav_sidebar = keynav.area({
  name = "nav_sidebar",
  hl_persist_on_area_switch = true,
  circular = true,
})

local sidebar = wibox.widget({
  spacing = dpi(8),
  layout  = wibox.layout.fixed.vertical,
})

bmcore:connect_signal("ready::json", function()
  sidebar:reset()
  nav_sidebar:reset()

  for i = 1, #bmcore.catnames do
    local catwibox = wibox.widget({
      markup = colorize(bmcore.catnames[i], beautiful.fg),
      font   = beautiful.base_small_font,
      align  = "start",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local navcat = keynav.navitem.textbox({
      widget  = catwibox,
      cat     = bmcore.catnames[i],
      release = function(self)
        bmcore:emit_signal("selected::category", self.cat)
      end
    })

    sidebar:add(catwibox)
    nav_sidebar:append(navcat)
  end
end)

return function()
  return sidebar, nav_sidebar
end
