
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄

-- Shows total checking and savings account balance.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local ledger = require("core.system.ledger")

local function create_balance_box(header_text)
  local header = wibox.widget({
    markup = colorize(header_text, beautiful.dash_bg),
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local total = wibox.widget({
    id = "total",
    font = beautiful.font_name .. "18",
    markup = colorize("$--.--", beautiful.dash_bg),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    {
      header,
      total,
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
end

local checking  = create_balance_box("Checking")
local savings   = create_balance_box("Savings")

ledger:connect_signal("update::balances", function(_)
  local checking_bal  = ledger:get_account_balance("checking")
  local savings_bal   = ledger:get_account_balance("savings")

  local txt = checking.children[1]
  txt.children[2]:set_markup_silently(colorize(checking_bal, beautiful.dash_bg))

  txt = savings.children[1]
  txt.children[2]:set_markup_silently(colorize(savings_bal, beautiful.dash_bg))
end)

return {
  nil, -- used to be total acct balance but i removed it
  box(checking, dpi(200), dpi(110), beautiful.main_accent),
  box(savings, dpi(200), dpi(110), beautiful.main_accent),
}

