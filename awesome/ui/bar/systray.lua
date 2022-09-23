
-- █▀ █▄█ █▀ ▀█▀ █▀█ ▄▀█ █▄█
-- ▄█ ░█░ ▄█ ░█░ █▀▄ █▀█ ░█░

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local animation = require("modules.animation")
local helpers = require("helpers")
local wbutton = require("ui.widgets.button")

local function create_systray()
	local systray = wibox.widget.systray()
  systray.base_size = dpi(10)
  systray.horizontal = false

	local widget = wibox.widget({
		widget = wibox.container.constraint,
		strategy = "max",
		height = dpi(0),
		{
			widget = wibox.container.margin,
			margins = dpi(10),
      {
			  systray,
        widget = wibox.container.place,
      },
		},
	})

	local system_tray_animation = animation:new({
		easing = animation.easing.linear,
		duration = 0.125,
		update = function(self, pos)
			widget.height = dpi(pos)
		end,
	})

	local arrow = wbutton.text.state ({
		text_normal_bg = beautiful.wibar_fg,
		normal_bg = beautiful.wibar_bg,
    font = beautiful.font,
    animate_size = false,
		size = 10,
		text = "",
		on_turn_on = function(self)
			system_tray_animation:set(400)
			self:set_text("")
		end,
		on_turn_off = function(self)
			system_tray_animation:set(0)
			self:set_text("")
		end,
	})

	return wibox.widget({
    widget,
    arrow,
    layout = wibox.layout.fixed.vertical,
	})
end

return create_systray()
