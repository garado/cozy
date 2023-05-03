
-- █░█ █    █░█ ▀█▀ █ █░░ █▀ 
-- █▄█ █    █▄█ ░█░ █ █▄▄ ▄█ 

local wibox = require("wibox")
local gshape = require("gears.shape")
local gtable = require("gears.table")
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

-- TODO: Need to fix (doesn't work right :/)
--- @function get_children_by_id
-- The fact that get_children_by_id isn't recursive makes no damn sense
function _ui.get_children_by_id(widget, target)
  if widget.id == target then
    return widget
  elseif widget.children then
    for i = 1, #widget.children do
      if widget.children[i].id == target then
        return widget.children[i]
      else
        return _ui.get_children_by_id(widget.children[i], target)
      end
    end
  elseif widget.widget then
    if widget.widget.id == target then
      return widget.widget
    elseif widget.widget.children then
      return _ui.get_children_by_id(widget.widget, target)
    end
  end
end

--- Create textbox with my preferred defaults.
function _ui.textbox(args)
  args = args or {}
  return wibox.widget({
    markup = args.markup or _ui.colorize(args.text or "Default text", args.color or beautiful.fg),
    valign = args.valign or "center",
    align  = args.align  or "left",
    font   = args.font   or beautiful.font_reg_s,
    forced_width  = args.width  or nil,
    forced_height = args.height or nil,
    widget = wibox.widget.textbox,
    -------
    _text  = args.text or "Default text",
    _color = args.color or beautiful.fg,
    update_text = function(self, text)
      self.markup = _ui.colorize(text, self._color)
    end,
    update_color = function(self, color)
      self.markup = _ui.colorize(self._text, color)
    end
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
      bg     = bg or beautiful.neutral[800],
      shape  = _ui.rrect(),
			widget = wibox.container.background,
		},
		margins = dpi(10),
		color   = "#FF000000",
		widget  = wibox.container.margin,
	})
end

return _ui
