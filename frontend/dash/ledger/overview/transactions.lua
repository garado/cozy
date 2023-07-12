
-- ▀█▀ █▀█ ▄▀█ █▄░█ █▀ ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- ░█░ █▀▄ █▀█ █░▀█ ▄█ █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Shows the most recent transactions using `ledger register` command.

local ui  = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local beautiful = require("beautiful")
local strutil = require("utils.string")
local ledger = require("backend.system.ledger")

-- Module-level variables
local TITLE_WIDTH   = dpi(250)
local ACCOUNT_WIDTH = TITLE_WIDTH
local DATE_WIDTH    = dpi(100)
local AMOUNT_WIDTH  = dpi(100)
local TEXT_HEIGHT   = dpi(20)

local function ledger_date_to_ts(date)
  local pattern = "(%d%d%d%d)/(%d%d)/(%d%d)"
  local xyear, xmon, xday = date:match(pattern)
  return os.time({
      year = xyear, month = xmon, day = xday,
      hour = 0, min = 0, sec = 0})
end

--- @function gen_transaction
-- @param tdata Table of transaction data
-- @brief Generate widget for a single transaction entry
local function gen_transaction(tdata)
  local t_date  = tdata[1]
  local t_title = tdata[2]
  local t_acnt  = tdata[3]

  -- In ledger-cli, income is negative and expenses are positive
  -- I do not understand why lol
  local t_amt   = tdata[5] * -1

  local title = ui.textbox({
    text = t_title,
    font = beautiful.font_bold_s,
    height = TEXT_HEIGHT,
    width  = TITLE_WIDTH
  })

  local account = ui.textbox({
    text = t_acnt,
    color = beautiful.neutral[300],
    height = TEXT_HEIGHT,
    width = ACCOUNT_WIDTH
  })

  local date = ui.textbox({
    text  = strutil.ts_to_relative( ledger_date_to_ts(t_date) ),
    align = "right",
    font  = beautiful.font_reg_s,
    height = TEXT_HEIGHT,
    width = DATE_WIDTH
  })

  local amount = ui.textbox({
    text = t_amt,
    color = t_amt > 0 and beautiful.green[300] or beautiful.red[300],
    align = "right",
    font = beautiful.font_reg_s,
    height = TEXT_HEIGHT,
    width = AMOUNT_WIDTH
  })

  return wibox.widget({
    {
      title,
      account,
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical,
    },
    date,
    amount,
    align = "right",
    forced_height = dpi(100),
    spacing = dpi(8),
    layout  = wibox.layout.fixed.horizontal,
  })
end

local transaction_entries = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.flex.vertical,
})

local transactions = wibox.widget({
  ui.textbox({
    text  = "Recent transactions",
    align = "center",
    font  = beautiful.font_med_m,
  }),
  transaction_entries,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

ledger:connect_signal("refresh", function(self)
  self:parse_recent_transactions()
end)

ledger:connect_signal("ready::transactions", function(_, tx)
  transaction_entries:reset()
  for i = 1, #tx do
    transaction_entries:add(gen_transaction(tx[i]))
  end
end)

return ui.dashbox(
  ui.place(transactions),
  dpi(1000), -- width
  dpi(2000)  -- height
)
