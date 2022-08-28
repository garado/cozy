
-- █▄▄ ▄▀█ █░░ ▄▀█ █▄░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █▀█ █░▀█ █▄▄ ██▄

-- Shows total bank balance

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")
local helpers = require("helpers")
local user_vars = require("user_variables")
local naughty = require("naughty")
local string = string

local ledger_file = user_vars.ledger.ledger_file

local header = wibox.widget({
  markup = helpers.ui.colorize_text("Total balance", beautiful.dash_header_fg),
  widget = wibox.widget.textbox,
  font = beautiful.font_name .. "Light 20",
  align = "left",
  valign = "center",
})

local function balance()
  local total = wibox.widget({
    markup = helpers.ui.colorize_text("$--.--", beautiful.fg),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "Light 30",
  })

  local checking = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "Light 12",
    font = beautiful.font_name .. "Light 10",
  })
  
  local savings = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "Light 12",
    font = beautiful.font_name .. "Light 10",
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

      if str_assets ~= nil then
        local markup = helpers.ui.colorize_text(str_stripped, beautiful.fg)
        total:set_markup_silently(markup)
      elseif str_checking ~= nil then
        local text = "Checking - " .. str_stripped
        local markup = helpers.ui.colorize_text(text, beautiful.subtext)
        checking:set_markup_silently(markup)
      elseif str_savings ~= nil then
        local text = "Savings - " .. str_stripped
        local markup = helpers.ui.colorize_text(text, beautiful.subtext)
        savings:set_markup_silently(markup)
      end
    end
  end)

  return wibox.widget ({
    total,
    checking,
    savings,
    layout = wibox.layout.fixed.vertical,
  })
end

local widget = wibox.widget({
  header,
  balance(),
  layout = wibox.layout.fixed.vertical,
})

return widget
