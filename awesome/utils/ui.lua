
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
    align  = args.align  or "center",
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

--- Create a simple, optionally stateful button
function _ui.button(_args)
  -- Set up defaults
  local args = {
    bg = beautiful.neutral[800],
    bg_mo = beautiful.neutral[700],
    color = beautiful.fg,
    text = "Default",
    shape = _ui.rrect(),
    margins = dpi(15),
    width = nil,
    height = nil,
    border_width = 0,
    border_color = beautiful.neutral[600],
    select_fg = beautiful.red[500],
    select_bg = beautiful.red[100],
    do_select_state = false,
    selected = false
  }
  gtable.crush(args, _args)

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
    fg_color = args.color,
    bg_color = args.bg,
    bg_mo    = args.bg_mo,
    shape    = args.shape,
    sel_fg   = args.select_fg,
    sel_bg   = args.select_bg,
    selected = false,
    do_select_state = args.do_select_state,

    update_bg = function(self, c)
      self.bg = c
      bg_color = args.bg
    end,

    update_fg = function(self, c)
      self.fg_color = c
      self.children[1].widget:update_color(c)
    end,

    select_toggle = function(self)
      self.selected = not self.selected
      if not self.selected then
        self:deselect()
      else
        self:select()
      end
    end,

    select = function(self)
      print('Select')
      self.bg = self.select_bg
      self.bg_color = self.select_bg
      if self.func then self.func() end
    end,

    deselect = function(self)
      print('Deselect')
      self.bg = self.bg_color
    end
  })

  local btn_cont = _ui.place(btn)

  btn_cont:connect_signal("mouse::enter", function()
    btn:update_bg(btn.bg_mo)
  end)

  btn_cont:connect_signal("mouse::leave", function()
    btn:update_bg(btn.bg_color)
  end)

  btn_cont:connect_signal("button::press", function()
    if btn.do_select_state then
      btn:select_toggle()
    else
      if self.func then self.func() end
    end
  end)

  return btn_cont
end

function _ui.dashbtn(text)
  return _ui.button({
    text = text,
    font = beautiful.font_med_s,
    color = beautiful.neutral[400],
    bg    = beautiful.neutral[800],
    bg_mo = beautiful.neutral[600],
    forced_height = dpi(10),
    border_width = dpi(0),
    do_select_state = true,
    select_bg = beautiful.primary[200],
    select_fg = beautiful.primary[700],
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
