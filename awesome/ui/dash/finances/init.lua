
-- █▀▀ █ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀ █▀
-- █▀░ █ █░▀█ █▀█ █░▀█ █▄▄ ██▄ ▄█

-- Financial dashboard integrated with Ledger
-- https://github.com/ledger/

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local user_vars = require("user_variables")
local area = require("modules.keynav.area")

local nav_finances = area:new({ name = "finances" })

local fin = "ui.dash.finances."
local transactions          = require(fin .. "transactions")
local balances              = require(fin .. "balances")
local spending      = require(fin .. "spending")
local budget        = require(fin .. "budget")
local nav_actions, actions  = require(fin .. "actions")()

nav_finances:append(nav_actions)

-- Assemble everything
local widget = wibox.widget({
  {
    {
      {
        balances[2],
        balances[3],
        layout = wibox.layout.flex.horizontal,
      },
      spending,
      transactions,
      forced_width = dpi(490),
      layout = wibox.layout.fixed.vertical,
    },
    {
      budget,
      actions,
      forced_width = dpi(430),
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(20),
  widget = wibox.container.margin,
})

return function()
  return widget, nav_finances
end
