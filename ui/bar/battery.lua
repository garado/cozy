
-- █▄▄ ▄▀█ █▀█ ▀   █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ █▀▄ ▄   █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
require("signal.battery")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

return function()
  local happy_color = beautiful.nord14
  local sad_color = beautiful.nord11
  local ok_color = beautiful.nord13
  local charging_color = beautiful.nord14
  
  local battery_decoration = wibox.widget({
    {
      wibox.widget.textbox,
      widget = wibox.container.background,
      bg = beautiful.xforeground,
      forced_width = dpi(8),
      forced_height = dpi(8),
			shape = function(cr, width, height)
				gears.shape.pie(cr, width, height, 0, math.pi)
			end,
    },
    direction = "south",
    widget = wibox.container.rotate(),
  })

  local battery_bar = wibox.widget({
    {
      {
        id = "batbar",
        max_value = 100,
        value = 50,
        widget = wibox.widget.progressbar,
        border_width = dpi(1),
        paddings = dpi(2),
        background_color = beautiful.transparent,
        border_color = beautiful.nord4,
      },
      forced_height = dpi(20),
      direction = "east",
      color = beautiful.xforeground,
      widget = wibox.container.rotate(),
    },
    margins = { left = dpi(11), right = dpi(11) },
    widget = wibox.container.margin,
  })

  local percentage = wibox.widget({
    id = "percent_text",
    text = "50%",
    font = beautiful.font_name .. "Medium 10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local battery = wibox.widget({
    {
      battery_decoration,
      battery_bar,
      spacing = dpi(-5),
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.vertical,
  })

  local widget = wibox.widget({
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
      battery,
      widget = wibox.container.margin,
    },
    percentage,
  })

  local last_value = 100
  awesome.connect_signal("signal::battery", function(value, state)
    battery_bar.value = value
    last_value = value
    percentage:set_text(math.floor(value))
    local batbar = battery_bar:get_children_by_id("batbar")[1] 
    batbar.color = happy_color

		--if charging_icon.visible then
	 --		batbar.color = charging_color
	 --	elseif value <= 15 then
	 --		batbar.color = sad_color
	 --	elseif value <= 30 then
	 --		batbar.color = ok_color
	 --	else
	 --		batbar.color = happy_color
	 --	end

    -- what is state?
		if state == 1 then
			--charging_icon.visible = true
			batbar.color = charging_color
		elseif last_value <= 15 then
			--charging_icon.visible = false
			batbar.color = sad_color
		elseif last_value <= 30 then
			--charging_icon.visible = false
			batbar.color = ok_color
		else
			--charging_icon.visible = false
			batbar.color = happy_color
		end
  end)
  
  return widget
end
