
-- █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

-- Credit: - https://github.com/Aire-One/awesome-battery_widget
--         - @rxyhn

require('backend.system.battery')

local wibox     = require("wibox")
local beautiful = require("beautiful")
local colorize  = require("utils.ui").colorize

local CHARGING = 1

local charging_color  = beautiful.green
local normal_color    = beautiful.fg_0
local low_color       = beautiful.red

local percentage = wibox.widget({
  markup  = "50",
  font    = beautiful.font_reg_xs,
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textbox,
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

  percentage:set_markup(colorize(math.floor(value), percent_color))
end)

return percentage
