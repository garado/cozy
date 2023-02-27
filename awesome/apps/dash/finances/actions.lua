
-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Buttons for opening and reloading ledger content.

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox  = require("wibox")
local ledger = require("core.system.ledger")
local dash   = require("core.cozy.dash")
local keynav = require("modules.keynav")
local ui     = require("helpers.ui")

local open_btn, nav_open = ui.simple_button({
  text   = "Open ledger",
  bg_off = beautiful.bg_3,
  bg_on  = beautiful.bg_4,
  release = function()
    ledger:open_ledger()
    dash:close()
  end
})

local reload_btn, nav_reload = ui.simple_button({
  text    = "Reload",
  bg_off  = beautiful.bg_3,
  bg_on   = beautiful.bg_4,
  release = function()
    ledger:reload()
  end
})

local actions = wibox.widget({
  {
    open_btn,
    reload_btn,
    spacing = dpi(20),
    layout  = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local nav_actions = keynav.area:new({
  name = "nav_actions",
  circular = true,
  children = {
    nav_open,
    nav_reload,
  }
})

local container = ui.box(actions, dpi(0), dpi(75), beautiful.dash_widget_bg)
nav_actions.widget = keynav.navitem.background({ widget = container })

return function()
  return container, nav_actions
end
