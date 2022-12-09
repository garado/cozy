
-- █▀▀ █ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀ █▀
-- █▀░ █ █░▀█ █▀█ █░▀█ █▄▄ ██▄ ▄█

-- Financial dashboard integrated with Ledger
-- https://github.com/ledger/

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local nav_finances = area:new({ name = "finances" })

local fin = "ui.dash.finances."
local transactions          = require(fin .. "transactions")
local balances              = require(fin .. "balances")
local budget        = require(fin .. "budget")
-- local keygrabber    = require(fin .. "keygrabber")(cash)
-- local edit          = require(fin .. "edit")(cash)
local nav_actions, actions  = require(fin .. "actions")()

nav_finances:append(nav_actions)

local widget = wibox.widget({
  {
    { -- Left side
      {
        balances[2],
        balances[3],
        layout = wibox.layout.flex.horizontal,
      },
      actions,
      budget,
      forced_width = dpi(420),
      layout = wibox.layout.fixed.vertical,
    },
    { -- Right side
      transactions,
      forced_width = dpi(850),
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
