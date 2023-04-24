
-- █░█ █    █░█ ▀█▀ █ █░░ █▀ 
-- █▄█ █    █▄█ ░█░ █ █▄▄ ▄█ 

local wibox = require("wibox")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local _ui = {}

--- For people with different screen resolutions, I hope this might be a solution.
-- There will be a config option one day and this will return dpi * scalar.
function _ui.dpi(px)
  return dpi(px)
end

function _ui.colorize(text, color)
  color = color or "#FF000000"
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

--- Create textbox with my preferred defaults.
function _ui.textbox(args)
  return wibox.widget.textbox({
    markup = args.markup or _ui.colorize("", beautiful.primary_0),
    valign = args.valign or "center",
    align  = args.align  or "center",
    font   = args.font   or beautiful.font_reg_xs,
    widget = wibox.widget.textbox,
  })
end

--- Horizontal padding.
function _ui.hpad(width)
	return wibox.widget({
		forced_width = width,
		layout = wibox.layout.fixed.horizontal,
	})
end

--- Vertical padding.
function _ui.vpad(height)
	return wibox.widget({
		forced_height = height,
		layout = wibox.layout.fixed.vertical,
	})
end

--- Create rounded rectangle.
function _ui.rrect(radius)
  radius = radius or beautiful.ui_border_radius
	return function(cr, width, height)
		gshape.rounded_rect(cr, width, height, radius)
	end
end


return _ui
