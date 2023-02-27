
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄

-- Shows total checking and savings account balance.

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox  = require("wibox")
local ui     = require("helpers.ui")
local ledger = require("core.system.ledger")

local NEG = -1
local NEU = 0
local POS = 1

local UP_ARROW   = "󱦴"
local DOWN_ARROW = "󱦷"

local arrow = wibox.widget({
  markup = ui.colorize("󰁜", beautiful.green),
  align  = "left",
  font   = beautiful.font_med_s,
  widget = wibox.widget.textbox,
  -----
  set_arrow = function(self, val)
    local color = (val > 0 and beautiful.green) or (val == 0 and beautiful.fg_0) or (val < 0 and beautiful.red)
    local text  = (val > 0 and UP_ARROW) or (val == 0 and '-') or (val < 0 and DOWN_ARROW)
    local mkup = ui.colorize(text, color)
    self:set_markup_silently(mkup)
  end
})

local percent = wibox.widget({
  markup = ui.colorize("+10.2%", beautiful.green),
  align  = "start",
  font   = beautiful.font_med_s,
  widget = wibox.widget.textbox,
  ----
  set_percent = function(self, val)
    local state = (val > 0 and POS) or (val == 0 and NEU) or (val < 0 and NEG)
    local percent_str = string.format("%.2f", val)

    local mkup = ""
    if state == POS then
      mkup = ui.colorize('+' .. percent_str .. '%', beautiful.green)
    elseif state == NEG then
      mkup = ui.colorize('-' .. percent_str .. '%', beautiful.red)
    elseif state == NEU then
      mkup = ui.colorize('--.--%', beautiful.fg_0)
    end

    self:set_markup_silently(mkup)
  end
})

local total_percent = wibox.widget({
  {
    {
      {
        arrow,
        margins = dpi(8),
        widget  = wibox.container.margin,
      },
      {
        percent,
        margins = {
          left   = -4,
          right  = dpi(10),
          top    = dpi(8),
          bottom = dpi(8),
        },
        widget  = wibox.container.margin,
      },
      spacing = dpi(00),
      layout  = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_width = dpi(120),
  shape        = ui.rrect(100),
  border_width = dpi(2),
  border_color = beautiful.green,
  widget = wibox.container.background,
})

local total = wibox.widget({
  {
    markup = ui.colorize("Total balance", beautiful.fg_1),
    font   = beautiful.font_med_s,
    widget = wibox.widget.textbox,
  },
  {
    id = "balance",
    markup = ui.colorize("$3412.00", beautiful.fg_0),
    font   = beautiful.font_med_xl,
    widget = wibox.widget.textbox,
  },
  {
    total_percent,
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(8),
  layout  = wibox.layout.fixed.vertical,
  --------
  update_balance = function(self, bal)
    local tbox = self.children[2]
    tbox:set_markup_silently(ui.colorize(bal, beautiful.fg_0))
  end,
})

local checking = wibox.widget({
  {
    markup = ui.colorize("Checking", beautiful.fg_1),
    font   = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
  },
  {
    id = "balance",
    markup = ui.colorize("$3412.00", beautiful.fg_0),
    font   = beautiful.font_med_m,
    widget = wibox.widget.textbox,
  },
  spacing = dpi(4),
  layout  = wibox.layout.fixed.vertical,
  --------
  update_balance = function(self, bal)
    local tbox = self.children[2]
    tbox:set_markup_silently(ui.colorize(bal, beautiful.fg_0))
  end
})

local savings = wibox.widget({
  {
    markup = ui.colorize("Savings", beautiful.fg_1),
    font   = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
  },
  {
    id = "balance",
    markup = ui.colorize("$3412.00", beautiful.fg_0),
    font   = beautiful.font_med_m,
    widget = wibox.widget.textbox,
  },
  spacing = dpi(4),
  layout  = wibox.layout.fixed.vertical,
  --------
  update_balance = function(self, bal)
    local tbox = self.children[2]
    tbox:set_markup_silently(ui.colorize(bal, beautiful.fg_0))
  end
})

local balances = wibox.widget({
  {
    {
      total,
      widget = wibox.container.place,
    },
    {
      checking,
      savings,
      spacing = dpi(10),
      layout  = wibox.layout.fixed.vertical,
    },
    spacing = dpi(35),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

-----

ledger:connect_signal("update::balances", function()
  local c_bal = ledger.checking or "$--.--"
  local s_bal = ledger.savings  or "$--.--"
  local t_bal = ledger.total    or "$--.--"
  checking:update_balance(c_bal)
  savings:update_balance(s_bal)
  total:update_balance(t_bal)
end)

-- update::balances signal means that ledger.total is ready
-- so this function needs to wait until after update::balances is called
ledger:connect_signal("update::percentdiff", function()
  local original = ledger.start_of_month_balance
  local curr = ledger.total
  curr = string.gsub(curr, "[^0-9.]", "")
  local percentdiff = (tonumber(curr) / tonumber(original)) * 100
  arrow:set_arrow(percentdiff)
  percent:set_percent(percentdiff)
end)

return ui.box(balances, dpi(0), dpi(200), beautiful.dash_widget_bg)
