
-- █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

-- Credits: - https://github.com/Aire-One/awesome-battery_widget
--          - @rxyhn

require("backend.system.battery")
local conf = require("cozyconf")
local theme = require("theme.colorschemes."..conf.theme_name.."."..conf.theme_style)

local ui = require("utils.ui")
local beautiful = require("beautiful")
local math = math

local CHARGING = 1

local charging_color  = beautiful.green[500]
local low_color       = beautiful.red[500]
local normal_color    = theme.pulsebar_fg_r == "dark" and beautiful.neutral[800] or beautiful.neutral[100]

local percentage = ui.textbox({
  text = "-",
  font = beautiful.font_reg_xs,
  align = "center",
  color = normal_color
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

  percentage:update_text(math.floor(value))
  percentage:update_color(percent_color)
end)

return percentage
