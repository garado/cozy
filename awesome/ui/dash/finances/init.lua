
-- █▀▀ █ █▄░█ ▄▀█ █▄░█ █▀▀ █▀▀ █▀
-- █▀░ █ █░▀█ █▀█ █░▀█ █▄▄ ██▄ ▄█

-- Financial dashboard integrated with Ledger
-- https://github.com/ledger/

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")
local helpers = require("helpers")
local user_vars = require("user_variables")
local animation = require("modules.animation")
local naughty = require("naughty")

local transactions = require("ui.dash.finances.transactions")
local balances = require("ui.dash.finances.balances")
local monthly_spending = require("ui.dash.finances.monthly_spending")
local monthly_budget = require("ui.dash.finances.monthly_budget")

local finances_header = wibox.widget({
  markup = helpers.ui.colorize_text("Finances", beautiful.fg),
  font = beautiful.alt_font_name .. "Medium 30",
  widget = wibox.widget.textbox,
})

-- Assemble everything
return wibox.widget({
  {
    finances_header,
    {
      {
        {
          balances[2],
          balances[3],
          layout = wibox.layout.flex.horizontal,
        },
        transactions,
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      {
        monthly_spending,
        monthly_budget,
        forced_width = dpi(600),
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(20),
  widget = wibox.container.margin,
})
