-- █▀█ █▀▀ █ █▀▄▀█ █▄▄ █░█ █▀█ █▀ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▀▄ ██▄ █ █░▀░█ █▄█ █▄█ █▀▄ ▄█ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

local beautiful = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local ledger = require("backend.system.ledger")
local gears = require("gears")

--- @function gen_account
-- @brief Generate a reimbursement entry widget
-- @param account{}   [1] amount owed; [2] account name
local function gen_account(data)
  local account = data[2]
  local amount = ""
  if string.find(data[1], "-") then
    amount = "you owe "..data[1]
  else
    amount = "they owe "..data[1]
  end

  local transactions = wibox.widget({
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  })

  local widget = wibox.widget({
    {
      ui.textbox({
        text = account,
        font = beautiful.font_med_s,
      }),
      nil,
      ui.textbox({
        text = amount,
      }),
      forced_width = dpi(1000),
      layout = wibox.layout.align.horizontal,
    },
    transactions,
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  })

  function widget:add_transaction(_data)
    self.transactions:add(ui.textbox({ text = _data }))
  end

  widget.account = account
  widget.transactions = transactions

  return widget
end

local content = wibox.widget({
  nil,
  {
    ui.textbox({
      text = "$",
      align = "center",
      color = beautiful.neutral[300],
      font = beautiful.font_bold_xxl,
    }),
    ui.textbox({
      text = "No reimbursements.",
      align = "center",
      color = beautiful.neutral[300],
    }),
    layout = wibox.layout.fixed.vertical,
  },
  nil,
  forced_height = dpi(400),
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

--- @function gen_transaction
-- @brief Generate widget showing transaction, then append it to the correct
--        account. The data fields are:
-- #    1: 2023/09/08
-- #    2: Utilities: PGE
-- #    3: Assets:Reimbursements:Kassidy
-- #    4: $
-- #    5: 38.54
-- #    6: !
local function gen_transaction(data)
  local widget = wibox.widget({
    ui.textbox({
      text = data[2],
      color = beautiful.neutral[300],
    }),
    nil,
    ui.textbox({ text = data[5] }),
    layout = wibox.layout.align.horizontal,
  })

  -- Put it with the correct account
  for _, container in ipairs(content.children) do
    if container.account == data[3] then
      container.transactions:add(widget)
    end
  end
end

local reimbursements = wibox.widget({
  ui.textbox({
    text   = "Reimbursements & Liabilities",
    align  = "center",
    height = dpi(30),
    font   = beautiful.font_med_m,
  }),
  ui.vpad(dpi(10)),
  content,
  forced_height = dpi(300),
  layout = wibox.layout.fixed.vertical,
})

ledger:connect_signal("refresh", function()
  ledger:parse_reimbursement_accounts()
end)

ledger:connect_signal("ready::reimbursements::accounts", function(_, data)
  if #data == 0 then return end
  content:reset()
  for i = 1, #data do
    local w = gen_account(data[i])
    content:add(w)
  end
  ledger:parse_reimbursement_transactions()
end)

ledger:connect_signal("ready::reimbursements::transactions", function(_, data)
  if #data == 0 then return end
  for i = 1, #data do
    gen_transaction(data[i])
  end
end)

return require("frontend.widget.yorha.basic_container")({
  text = "Reimbursements + liabilities",
  widget = wibox.container.place(content),
  height = dpi(300),
})

-- return ui.dashbox(reimbursements)
