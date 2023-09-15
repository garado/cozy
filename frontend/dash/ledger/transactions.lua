
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
local TITLE_WIDTH   = dpi(240)
local DATE_WIDTH    = TITLE_WIDTH
local ICON_WIDTH    = dpi(32)
local AMOUNT_WIDTH  = dpi(100)
local TEXT_HEIGHT   = dpi(20)

local function ledger_date_to_ts(date)
  local pattern = "(%d%d%d%d)/(%d%d)/(%d%d)"
  local xyear, xmon, xday = date:match(pattern)
  return os.time({
      year = xyear, month = xmon, day = xday,
      hour = 0, min = 0, sec = 0})
end

local function pick_transaction_icon(title, account)
  -- Default icon
  local icon = ""

  local account_icons = {
    { "󰉛", "Food"       },
    { "", "Household"  },
    { "", "Education"  },
    { "", "Personal"   },
    { "", "Hobby"      },
    { "", "Gifts"      },
    { "󰄛", "Pets"       },
    { "", "Bills"      },
    { "󰄋", "Transportation" },
    { "󰉚", "Restaurant" },
  }

  -- More specialized stuff based on transaction title
  local title_icons = {
    { "", "Spotify"    },
    { "", "Amazon"     },
    { "󱐋", "Utilities"  },
    { "󱐋", "PGE"        },
  }

  for i = #title_icons, 1, -1 do
    if string.find(title, title_icons[i][2]) then
      return title_icons[i][1]
    end
  end

  for i = #account_icons, 1, -1 do
    if string.find(account, account_icons[i][2]) then
      return account_icons[i][1]
    end
  end

  return icon
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

  local icon = wibox.widget({
    {
      ui.textbox({
        text  = pick_transaction_icon(t_title, t_acnt),
        color = beautiful.primary[700],
        align = "center",
        width = dpi(20),
      }),
      widget = wibox.container.place,
    },
    bg = beautiful.primary[200],
    shape = require("gears").shape.circle,
    forced_width = ICON_WIDTH,
    forced_height = ICON_WIDTH,
    widget = wibox.container.background,
  })

  local title = ui.textbox({
    text = t_title,
    font = beautiful.font_bold_s,
    height = TEXT_HEIGHT,
    width  = TITLE_WIDTH
  })

  local date = ui.textbox({
    text   = strutil.ts_to_relative( ledger_date_to_ts(t_date) ),
    font   = beautiful.font_reg_s,
    color  = beautiful.neutral[300],
    height = TEXT_HEIGHT,
    width  = DATE_WIDTH
  })

  local amount = ui.textbox({
    text  = ledger:format(t_amt),
    color = t_amt > 0 and beautiful.green[300] or beautiful.red[300],
    align = "right",
    font = beautiful.font_reg_s,
    height = TEXT_HEIGHT,
    width = AMOUNT_WIDTH
  })

  return wibox.widget({
    {
      icon,
      widget = wibox.container.place,
      forced_width = ICON_WIDTH * 1.5,
    },
    {
      title,
      date,
      spacing = dpi(4),
      layout = wibox.layout.fixed.vertical,
    },
    amount,
    align   = "right",
    spacing = dpi(8),
    forced_height = TEXT_HEIGHT * 2,
    layout  = wibox.layout.fixed.horizontal,
  })
end

local transaction_entries = wibox.widget({
  ui.placeholder("No transaction entries yet."),
  spacing = dpi(15),
  layout  = wibox.layout.flex.vertical,
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
  wibox.container.place(transaction_entries),
  dpi(410), -- width
  dpi(2000)  -- height
)
