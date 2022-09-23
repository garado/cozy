
-- █░█ █   █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀
-- █▄█ █   █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█

local wibox = require("wibox")
local gears = require("gears")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local capi = { mouse = mouse }

local _ui = {}

-- for dashboard
-- credit: @rxhyn
function _ui.create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
	local box_container = wibox.container.background()
  box_container.bg = bg_color
	box_container.forced_height = height
	box_container.forced_width = width
  box_container.shape = gears.shape.rounded_rect

	local boxed_widget = wibox.widget({
		--- Add margins
		{
			--- Add background color
			{
				--- The actual widget goes here
				widget_to_be_boxed,
				top = dpi(15),
				bottom = dpi(15),
				left = dpi(15),
				right = dpi(15),
				widget = wibox.container.margin,
			},
			widget = box_container,
		},
		margins = dpi(10),
		color = "#FF000000",
		widget = wibox.container.margin,
	})
	return boxed_widget
end

function _ui.colorize_text(text, color)
	return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function _ui.create_dash_widget_header(text)
  return wibox.widget({
    markup = _ui.colorize_text(text, beautiful.dash_header_fg),
    font = beautiful.alt_font_name .. "Light 20",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })
end

function _ui.vertical_pad(height)
	return wibox.widget({
		forced_height = height,
		layout = wibox.layout.fixed.vertical,
	})
end

function _ui.horizontal_pad(width)
	return wibox.widget({
		forced_width = width,
		layout = wibox.layout.fixed.horizontal,
	})
end

function _ui.rrect(radius)
	return function(cr, width, height)
		gshape.rounded_rect(cr, width, height, radius)
	end
end

function _ui.add_hover_cursor(w, hover_cursor)
	local original_cursor = "left_ptr"

	w:connect_signal("mouse::enter", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = hover_cursor
		end
	end)

	w:connect_signal("mouse::leave", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = original_cursor
		end
	end)
end

return _ui
