
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

local ledger_file = user_vars.dash.ledger_file

local header = wibox.widget({
  markup = helpers.ui.colorize_text("Total balance", beautiful.nord3),
  widget = wibox.widget.textbox,
  font = beautiful.header_font_name .. "Light 20",
  align = "left",
  valign = "center",
})

local function balance()
  local total = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "Light 30",
  })

  local cmd = "ledger -f " .. ledger_file .. " balance checking savings | tail -1 "
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local amount = string.gsub(stdout, "%s", "")
    local markup = helpers.ui.colorize_text(amount, beautiful.xforeground)
    total:set_markup_silently(markup)
  end)

  return total
end

local widget = wibox.widget({
  header,
  balance(),
  layout = wibox.layout.fixed.vertical,
})

return widget
