
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄

-- Shows total bank balance

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local user_vars = require("user_variables")

local string = string

local ledger_file = user_vars.ledger.ledger_file

local header = wibox.widget({
  markup = helpers.ui.colorize_text("Total balance", beautiful.dash_bg),
  widget = wibox.widget.textbox,
  font = beautiful.font_name .. "Regular 12",
  align = "left",
  valign = "center",
})

local function get_account_value(header_text, account)
  local header = wibox.widget({
    markup = helpers.ui.colorize_text(header_text, beautiful.dash_bg),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "Light 12",
    align = "center",
    valign = "center",
  })

  local total = wibox.widget({
    markup = helpers.ui.colorize_text("$--.--", beautiful.dash_bg),
    widget = wibox.widget.textbox,
    font = beautiful.alt_font_name .. "20",
    align = "center",
    valign = "center",
  })
  
  -- Get data
  -- This assumes only one savings/checking account, could be easily extended though
  local cmd = "ledger -f " .. ledger_file .. " balance checking savings"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Split into lines
    for str in string.gmatch(stdout, "([^\n]+)") do
      -- Look for line containing "Assets" "Checking" and "Savings"
      local str_assets = string.find(str, "Assets")
      local str_checking  = string.find(str, "Checking")
      local str_savings = string.find(str, "Savings")
        
      -- Remove everything except #s, periods, and dollar signs from string
      local str_stripped = string.gsub(str, "[^0-9$.]", "")

      if str_assets ~= nil and account == "balance" then
        local markup = helpers.ui.colorize_text(str_stripped, beautiful.dash_bg)
        total:set_markup_silently(markup)
      elseif str_checking ~= nil and account == "checking" then
        local text = str_stripped
        local markup = helpers.ui.colorize_text(text, beautiful.dash_bg)
        total:set_markup_silently(markup)
      elseif str_savings ~= nil and account == "savings" then
        local text = str_stripped
        local markup = helpers.ui.colorize_text(text, beautiful.dash_bg)
        total:set_markup_silently(markup)
      end
    end
  end)

  return wibox.widget({
    {
      header,
      total,
      spacing = dpi(10),
      widget = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
end

local _bal = get_account_value("Total balance", "balance")
local _checking = get_account_value("Checking", "checking")
local _savings = get_account_value("Savings", "savings")
local bal = helpers.ui.create_boxed_widget(_bal, dpi(200), dpi(110), beautiful.main_accent)
local checking = helpers.ui.create_boxed_widget(_checking, dpi(200), dpi(110), beautiful.main_accent)
local savings = helpers.ui.create_boxed_widget(_savings, dpi(200), dpi(110), beautiful.main_accent)

return { bal, checking, savings }
