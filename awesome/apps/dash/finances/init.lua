
-- █▀▀ █ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀ █▀
-- █▀░ █ █░▀█ █▀█ █░▀█ █▄▄ ██▄ ▄█

-- Financial dashboard integrated with Ledger
-- https://github.com/ledger/

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local transactions  = require(... .. ".transactions")
local balances      = require(... .. ".balances")
local budget        = require(... .. ".budget")
local actions, nav_actions = require(... .. ".actions")()

local nav_finances = area({
  name = "finances",
  children = {
    nav_actions
  }
})

local widget = wibox.widget({
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
    forced_width = dpi(900),
    layout = wibox.layout.fixed.vertical,
  },
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return widget, nav_finances
end
