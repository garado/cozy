
-- ▀█▀ █▀█ ▄▀█ █▄░█ █▀ ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ░█░ █▀▄ █▀█ █░▀█ ▄█ █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers.ui").colorize_text
local wheader = require("helpers.ui").create_dash_widget_header
local box = require("helpers.ui").create_boxed_widget
local ledger = require("core.system.ledger")

local transaction_history

local function create_transaction_entry(date, title, category, amount)
  -- Determine color of amount text
  -- Green for income, red for expense
  local i, _ = string.find(category, "Expenses:")
  local amount_color, prefix
  if i == nil then
    prefix = "+"
    amount_color = beautiful.green
  else
    prefix = "-"
    amount_color = beautiful.red
  end

  local date_text = wibox.widget({
    markup = colorize(date, beautiful.fg_0),
    font = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
  })

  local title_text = wibox.widget({
    markup = colorize(title, beautiful.fg_0),
    font = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
    ellipsize = "end",
  })

  local amount_ = "$" .. amount
  amount_ = string.gsub(amount_, "-", "")
  local amount_text = wibox.widget({
    forced_width = dpi(80),
    markup = colorize(prefix .. amount_, amount_color),
    font   = beautiful.font_reg_s,
    align  = "right",
    widget = wibox.widget.textbox,
  })

  category = category:gsub("Expenses:", "")
  category = category:gsub("Income:", "")
  local category_text = wibox.widget({
    markup = colorize(category, beautiful.fg_0),
    font   = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
    ellipsize = "end",
    forced_width = dpi(200),
  })

  local widget = wibox.widget({
    {
      date_text,
      amount_text,
      category_text,
      title_text,
      forced_height = dpi(20),
      spacing = dpi(30),
      layout = wibox.layout.fixed.horizontal,
    },
    margins = dpi(2),
    widget = wibox.container.margin,
  })

  transaction_history:add(widget)
end

--------------------------------------------

transaction_history = wibox.widget({
  spacing = dpi(4),
  layout = wibox.layout.flex.vertical,
})

local widget = wibox.widget({
  wheader("Transaction History"),
  {
    transaction_history,
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  layout = wibox.layout.fixed.vertical,
  widget = wibox.container.place,
})

ledger:connect_signal("update::transactions", function(_)
  local t = ledger.transactions
  transaction_history:reset()
  for i = 1, #t do
    create_transaction_entry(t[i][1], t[i][2], t[i][3], t[i][4])
  end
end)

return box(widget, dpi(0), dpi(900), beautiful.dash_widget_bg)
