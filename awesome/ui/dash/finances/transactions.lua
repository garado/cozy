
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

return function()
  local ledger_file = user_vars.ledger.ledger_file
 
  local transaction_header = wibox.widget({
    markup = helpers.ui.colorize_text("Transaction history", beautiful.nord3),
    font = beautiful.header_font_name .. "Light 20",
    widget = wibox.widget.textbox,
  })

  -- create_transaction_entry() will populate this widget with entries
  local transaction_history = wibox.widget({
    transaction_header,
    spacing = dpi(2),
    layout = wibox.layout.fixed.vertical,
  })

  local function create_transaction_entry(date, title, category, amount)
    
    -- Determine color of amount
    -- Green for income, red for expense
    local i, j = string.find(category, "Expenses:")
    local amount_color
    if i == nil then
      amount_color = beautiful.nord14
    else
      amount_color = beautiful.nord11
    end

    local date_text = wibox.widget({
      markup = helpers.ui.colorize_text(date, beautiful.xforeground),
      font = beautiful.header_font_name .. "14",
      widget = wibox.widget.textbox,
    })
    
    local title_text = wibox.widget({
      markup = helpers.ui.colorize_text(title, beautiful.xforeground),
      font = beautiful.header_font_name .. "14",
      widget = wibox.widget.textbox,
    })
    
    local amount_ = "$" .. amount
    amount_ = string.gsub(amount_, "-", "")
    local amount_text = wibox.widget({
      markup = helpers.ui.colorize_text(amount_, amount_color),
      font = beautiful.header_font_name .. "14",
      widget = wibox.widget.textbox,
      forced_width = dpi(120),
    })

    local category_text = wibox.widget({
      markup = helpers.ui.colorize_text(category, beautiful.xforeground),
      widget = wibox.widget.textbox,
    })

    local widget = wibox.widget({
      date_text,
      amount_text,
      title_text,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    })

    transaction_history:add(widget)
  end
 
  -- Grab last 10 transactions
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
      local title = t[2]
      local category = t[3]
      local amount = t[4]
      create_transaction_entry(date, title, category, amount)
    end
  end)

  return transaction_history
end
