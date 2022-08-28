
-- ▀█▀ █▀█ ▄▀█ █▄░█ █▀ ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ░█░ █▀▄ █▀█ █░▀█ ▄█ █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

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

local ledger_file = user_vars.ledger.ledger_file

-- create_transaction_entry() will populate this widget with entries
local transaction_history = wibox.widget({
  spacing = dpi(2),
  layout = wibox.layout.flex.vertical,
})

local function create_transaction_entry(date, title, category, amount)
  
  -- determine color of amount
  -- green for income, red for expense
  local i, j = string.find(category, "Expenses:")
  local amount_color
  if i == nil then
    amount_color = beautiful.green
  else
    amount_color = beautiful.red
  end

  local date_text = wibox.widget({
    markup = helpers.ui.colorize_text(date, beautiful.fg),
    font = beautiful.font_name .. "12",
    widget = wibox.widget.textbox,
  })
  
  local title_text = wibox.widget({
    markup = helpers.ui.colorize_text(title, beautiful.fg),
    font = beautiful.font_name .. "12",
    widget = wibox.widget.textbox,
    ellipsize = "end",
    forced_width = dpi(250),
  })
  
  local amount_ = "$" .. amount
  amount_ = string.gsub(amount_, "-", "")
  local amount_text = wibox.widget({
    markup = helpers.ui.colorize_text(amount_, amount_color),
    font = beautiful.font_name .. "12",
    widget = wibox.widget.textbox,
    forced_width = dpi(90),
  })

  local category_text = wibox.widget({
    markup = helpers.ui.colorize_text(category, beautiful.fg),
    widget = wibox.widget.textbox,
  })

  local widget = wibox.widget({
    {
      date_text,
      amount_text,
      title_text,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    margins = dpi(2),
    widget = wibox.container.margin,
  })

  transaction_history:add(widget)
end

-- grab last 10 transactions
local cmd = "ledger -f " .. ledger_file .. " csv expenses reimbursements income | head -10"
awful.spawn.easy_async_with_shell(cmd, function(stdout)
  for str in string.gmatch(stdout, "([^\n]+)") do
    local t = { }
    for field in string.gmatch(str, "([^,]+)") do
      field = string.gsub(field, "\"", "")
      if field ~= "" and field ~= "$" then
        table.insert(t, field)
      end
    end
   
    local date = t[1]
    local pattern = "(%d%d%d%d)/(%d%d)/(%d%d)"
    local xyear, xmon, xday = date:match(pattern)
    local ts = os.time({ year = xyear, month = xmon, day = xday })
    local format_date = os.date("%a %m/%d", ts) .. " "
    local title = t[2]
    local category = t[3]
    local amount = t[4]
    amount = string.format("%.2f", tonumber(amount))
    create_transaction_entry(format_date, title, category, amount)
  end
end)

local widget = wibox.widget({
  helpers.ui.create_dash_widget_header("Transaction history"),
  {
    transaction_history,
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  layout = wibox.layout.fixed.vertical,
  widget = wibox.container.place,
})

return helpers.ui.create_boxed_widget(widget, dpi(500), dpi(340), beautiful.dash_widget_bg) 
