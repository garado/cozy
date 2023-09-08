
-- █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

-- Credit: - https://github.com/Aire-One/awesome-battery_widget
--         - @rxyhn

require("backend.system.battery")

local conf = require("cozyconf")
local wibox = require("wibox")
local beautiful = require("beautiful")
local floor = math.floor

local CHARGING = 1

local low_color      = beautiful.red[500]
local normal_color   = conf.pulsebar_fg_r =="dark" and beautiful.neutral[900] or beautiful.neutral[100]
local charging_color = beautiful.green[500]

local percentage = wibox.widget({
  {
    font = beautiful.font_reg_xs,
    markup = "50",
    align  = "center",
    widget = wibox.widget.textbox,
  },
  fg = normal_color,
  widget = wibox.container.background,
})

awesome.connect_signal("signal::battery", function(value, state)
  local last_value = value
  local percent_color

  if state == CHARGING then
		percent_color = charging_color
  elseif last_value <= 20 then
    percent_color = low_color
  else
    percent_color = normal_color
  end

  percentage.widget.text = floor(value)
  percentage:set_fg(percent_color)
end)

return percentage
