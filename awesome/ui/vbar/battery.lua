
-- █▄▄ ▄▀█ █▀█ ▀   █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ █▀▄ ▄   █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
require("signal.battery")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")

local charging_color = beautiful.wibar_bat_grn
local low_color = beautiful.wibar_bat_red
local normal_color = beautiful.wibar_bat_nrml

local percentage = wibox.widget({
  id = "percent_text",
  markup = "50",
  font = beautiful.font_name .. "10",
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

local last_value = 100
awesome.connect_signal("signal::battery", function(value, state)
  local last_value = value

  local percent_color
  if state == 1 then
		percent_color = charging_color
	elseif last_value <= 20 then
    percent_color = low_color
  else
    percent_color = normal_color
  end

  percentage:set_markup(helpers.ui.colorize_text(math.floor(value), percent_color))
end)

return percentage 
