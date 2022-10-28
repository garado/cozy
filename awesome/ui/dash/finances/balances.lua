
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄

-- Shows total bank balance

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local config = require("config")
local widgets = require("ui.widgets")
local string = string
local ledger_file = config.ledger.ledger_file

local function get_account_value(header_text, account)
  local header = widgets.text({
    text = string.upper(header_text),
    color = beautiful.dash_bg,
    size = 11,
    halign = "center",
    valign = "center",
  })

  local total = widgets.text({
    text = "$--.--",
    color = beautiful.dash_bg,
    halign = "center",
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

      -- Remove everything except # $ . from string
      local str_stripped = string.gsub(str, "[^0-9$.]", "")
      if str_assets ~= nil and account == "balance" then
        total:set_text(str_stripped)
      elseif str_checking ~= nil and account == "checking" then
        total:set_text(str_stripped)
      elseif str_savings ~= nil and account == "savings" then
        total:set_text(str_stripped)
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

local bal = get_account_value("Total balance", "balance")
local bal_box = helpers.ui.create_boxed_widget(bal, dpi(200), dpi(110), beautiful.main_accent)

local checking = get_account_value("Checking", "checking")
local checking_box = helpers.ui.create_boxed_widget(checking, dpi(200), dpi(110), beautiful.main_accent)

local savings = get_account_value("Savings", "savings")
local savings_box = helpers.ui.create_boxed_widget(savings, dpi(200), dpi(110), beautiful.main_accent)

return {
  bal_box,
  checking_box,
  savings_box,
}
