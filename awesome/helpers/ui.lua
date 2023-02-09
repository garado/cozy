
-- █░█ █   █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀
-- █▄█ █   █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█

local wibox  = require("wibox")
local gears  = require("gears")
local gshape = require("gears.shape")
local naughty    = require("naughty")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi  = xresources.apply_dpi
local capi = { mouse = mouse }

local control = require("core.cozy.control")

local _ui = {}

-- For dashboard
-- credit: @rxhyn
function _ui.create_boxed_widget(widget_to_be_boxed, width, height, bg_color)
	return wibox.widget({
		{
			{
				widget_to_be_boxed,
        margins = dpi(15),
				widget  = wibox.container.margin,
			},
      forced_height = height or nil,
      forced_width  = width or nil,
      bg     = bg_color,
      shape  = gears.shape.rounded_rect,
			widget = wibox.container.background,
		},
		margins = dpi(10),
		color   = "#FF000000",
		widget  = wibox.container.margin,
	})
end

function _ui.box(widget_to_be_boxed, width, height, bg_color)
	return wibox.widget({
		{
			{
				widget_to_be_boxed,
        margins = dpi(15),
				widget  = wibox.container.margin,
			},
      forced_height = height or nil,
      forced_width  = width or nil,
      bg     = bg_color,
      shape  = gears.shape.rounded_rect,
			widget = wibox.container.background,
		},
		margins = dpi(10),
	  widget  = wibox.container.margin,
	})
end

function _ui.colorize_text(text, color)
  color = color or "#FF000000"
	return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function _ui.colorize(text, color)
  color = color or "#FF000000"
	return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function _ui.create_dash_widget_header(text)
  return wibox.widget({
    markup = _ui.colorize_text(text, beautiful.primary_0),
    font   = beautiful.font_med_m,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })
end


function _ui.vpad(height)
	return wibox.widget({
		forced_height = height,
		layout = wibox.layout.fixed.vertical,
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
  radius = radius or beautiful.ui_border_radius
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

function _ui.simple_button(args)
  local text = args.text
  local fg   = args.fg or beautiful.fg_0
  local font = args.font or beautiful.font_reg_s
  local bg   = args.bg or beautiful.bg_3
  local shape   = args.shape
  local width   = args.width
  local height  = args.height
  local margins = args.margins or dpi(6)

  local button = wibox.widget({
    {
      {
        {
          id     = "textbox",
          markup = _ui.colorize_text(text, fg),
          align  = "center",
          valign = "center",
          font   = font,
          widget = wibox.widget.textbox,
        },
        margins = margins,
        widget  = wibox.container.margin,
      },
      forced_width  = width,
      forced_height = height,
      shape  = shape or gears.shape.rounded_rect,
      bg     = bg,
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
    ------
    get_bg_wibox = function(self)
      return self.children[1]
    end,
    get_text_wibox = function(self)
      return self.children[1].children[1].children[1]
    end,
  })

  local nav_button = require("modules.keynav").navitem.background({
    widget  = button:get_bg_wibox(),
    bg_off  = args.bg      or beautiful.bg_3,
    bg_on   = args.bg_on   or beautiful.bg_6,
    release = args.release or nil
  })

  return button, nav_button
end

function _ui.quick_action(name, icon)
  local qa = _ui.simple_button({
    text   = icon,
    bg     = beautiful.bg_3,
    width  = dpi(50),
    height = dpi(50),
  })

  local nav_qa = require("modules.keynav").navitem.background({
    widget = qa.children[1],
    bg_off = beautiful.bg_3,
    bg_on  = beautiful.bg_4,
    name   = name,
    custom_on = function(self)
      control:emit_signal("qaction::selected", self.name)
    end,
  })

  return qa, nav_qa
end

function _ui.qa_notify(title, msg, timeout)
  naughty.notification {
    app_name = "Quick actions",
    title    = title,
    message  = msg,
    timeout  = timeout or 2,
  }
end


return _ui
