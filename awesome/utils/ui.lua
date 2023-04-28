
-- █░█ █    █░█ ▀█▀ █ █░░ █▀ 
-- █▄█ █    █▄█ ░█░ █ █▄▄ ▄█ 

local wibox = require("wibox")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local clrutils = require("utils.color")

local _ui = {}

--- For people with different screen resolutions, I hope this might be a solution.
-- There will be a config option one day and this will return dpi * scalar to scale
-- stuff up/down.
function _ui.dpi(px)
  return dpi(px)
end

function _ui.colorize(text, color)
  color = color or beautiful.fg
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

--- Create textbox with my preferred defaults.
function _ui.textbox(args)
  args = args or {}
  return wibox.widget({
    markup = args.markup or _ui.colorize(args.text or "Default text", args.color or beautiful.fg),
    valign = args.valign or "center",
    align  = args.align  or "center",
    font   = args.font   or beautiful.font_reg_s,
    widget = wibox.widget.textbox,
    -------
    _text  = args.text or "Default text",
    _color = args.color or beautiful.fg,
    new_text = function(self, text)
      self.markup = _ui.colorize(text, self._color)
    end,
    new_color = function(self, color)
      self.markup = _ui.colorize(self._text, color)
    end
  })
end

--- Create a simple button
function _ui.button(args)
  args = args or {}
  args.bg = args.bg or beautiful.neutral[800]
  args.bg_mo = args.bg_mo or beautiful.neutral[700]
  args.color = args.color or beautiful.fg
  args.text = args.text or "Default"
  args.shape = args.shape or _ui.rrect()
  args.margins = args.margins or dpi(15)
  args.width = args.width or nil
  args.height = args.height or nil
  args.border_width = args.border_width or 0
  args.border_color = args.border_color or beautiful.neutral[600]

  local btn = wibox.widget({
    {
      _ui.textbox({
        font = args.font,
        markup = args.markup,
        text = args.text,
        color = args.color,
      }),
      margins = args.margins,
      widget = wibox.container.margin,
    },
    bg = args.bg,
    border_width = args.border_width,
    border_color = args.border_color,
    widget = wibox.container.background,
    forced_width = args.width,
    forced_height = args.height,
    ------
    bg_mo = args.bg_mo,
    shape = args.shape,
    bg_color = args.bg,
    update_bg = function(self, c)
      self.bg = c
    end,
  })

  local btn_cont = _ui.place(btn)

  btn_cont:connect_signal("mouse::enter", function()
    btn:update_bg(btn.bg_mo)
  end)

  btn_cont:connect_signal("mouse::leave", function()
    btn:update_bg(btn.bg_color)
  end)

  return btn_cont
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

function _ui.place(content, args)
  args = args or {}
  return wibox.widget({
    {
      content,
      widget = wibox.container.place,
    },
    widget  = wibox.container.margin,
    margins = args.margins or dpi(5)
  })
end

--- Create rounded rectangle.
function _ui.rrect(radius)
  radius = radius or beautiful.ui_border_radius
	return function(cr, width, height)
		gshape.rounded_rect(cr, width, height, radius)
	end
end

--- (Dashboard) Put a box around a widget.
function _ui.dashbox(content, width, height, bg)
	return wibox.widget({
		{
			{
				content,
        margins = dpi(15),
				widget  = wibox.container.margin,
			},
      forced_height = height or nil,
      forced_width  = width or nil,
      bg     = bg,
      shape  = gshape.rounded_rect,
			widget = wibox.container.background,
		},
		margins = dpi(10),
		color   = "#FF000000",
		widget  = wibox.container.margin,
	})
end

return _ui
