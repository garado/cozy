
-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Buttons for opening and reloading Ledger content.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")
local box = require("helpers.ui").create_boxed_widget
local ledger = require("core.system.ledger")
local dash = require("core.cozy.dash")

local area = require("modules.keynav.area")
local elevated = require("modules.keynav.navitem").Elevated
local dashwidget = require("modules.keynav.navitem").Dashwidget

local nav_actions = area:new({
  name = "nav_actions",
  circular = true,
})

local open_button = widgets.button.text.normal({
  text = "Open ledger",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.cash_action_btn,
  animate_size = true,
  font = beautiful.font,
  size = 12,
  on_release = function()
    ledger:open_ledger()
    dash:close()
  end,
})

local reload_button = widgets.button.text.normal({
  text = "Reload",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.cash_action_btn,
  animate_size = true,
  font = beautiful.font,
  size = 12,
  on_release = function()
    ledger:reload()
  end
})

nav_actions:append(elevated:new(open_button))
nav_actions:append(elevated:new(reload_button))

local actions = wibox.widget({
  {
    {
      open_button,
      reload_button,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  widget = wibox.container.background,
})

local container = box(actions, dpi(0), dpi(80), beautiful.dash_widget_bg)
nav_actions.widget = dashwidget:new(container)

return function()
  return nav_actions, container
end

