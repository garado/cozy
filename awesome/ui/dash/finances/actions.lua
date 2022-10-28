
-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")
local helpers = require("helpers")
local config = require("config")

local area = require("modules.keynav.area")
local elevated = require("modules.keynav.navitem").Elevated
local dashwidget = require("modules.keynav.navitem").Dashwidget

local nav_actions = area:new({
  name = "nav_actions",
  circular = true,
})

local ledger_dir = config.ledger.ledger_dir
local open_button = widgets.button.text.normal({
  text = "Open ledger",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.cash_action_btn,
  animate_size = true,
  font = beautiful.font,
  size = 12,
  on_release = function()
    local cmd = "kitty sh -c 'nvim -p " .. ledger_dir .. "*'"
    awesome.emit_signal("dash::toggle")
    awful.spawn(cmd, {
      floating = true,
      geometry = {x=360, y=90, height=900, width=1200},
      placement = awful.placement.centered,
    })
  end
})

local reload_button = widgets.button.text.normal({
  text = "Reload ledger",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.cash_action_btn,
  animate_size = true,
  font = beautiful.font,
  size = 12,
  on_release = function()
    awesome.emit_signal("dash::reload_ledger")
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

local container = helpers.ui.create_boxed_widget(actions, dpi(0), dpi(80), beautiful.dash_widget_bg)
nav_actions.widget = dashwidget:new(container)

return function()
  return nav_actions, container
end
