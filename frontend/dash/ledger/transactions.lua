
-- ▀█▀ █▀█ ▄▀█ █▄░█ █▀ ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- ░█░ █▀▄ █▀█ █░▀█ ▄█ █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Shows the most recent transactions using `ledger register` command.

local ui  = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local beautiful = require("beautiful")
local ledger = require("backend.system.ledger")

local transactions = ui.textbox({
  text  = "Transactions",
  font  = beautiful.font_med_m,
  align = "center",
})

-- Connect to backend stuff
ledger:parse_recent_transactions()

ledger:connect_signal("ready::transactions", function(_, tx)
end)

return ui.dashbox(
  transactions,
  dpi(1000), -- width
  dpi(2000)  -- height
)
