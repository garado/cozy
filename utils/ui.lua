
-- █░█ █    █░█ ▀█▀ █ █░░ █▀
-- █▄█ █    █▄█ ░█░ █ █▄▄ ▄█

local wibox      = require("wibox")
local gshape     = require("gears.shape")
local gtable     = require("gears.table")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi        = xresources.apply_dpi
local strutil    = require("utils.string")

local _ui        = {}

-- █░█░█ █ █▄▄ █▀█ ▀▄▀
-- ▀▄▀▄▀ █ █▄█ █▄█ █░█

--- @method textbox
-- @brief Create textbox with my preferred defaults.
function _ui.textbox(userargs)
  local args = {
    color          = beautiful.neutral[100],
    text           = "",
    valign         = "center",
    align          = "left",
    font           = beautiful.font_reg_s,
    width          = nil,
    height         = nil,
    ellipsize      = "end",
    letter_spacing = nil,
    strikethrough  = false,
  }
  gtable.crush(args, userargs or {})
  args.text = tostring(args.text) -- just making sure

  -- Handle special characters
  if args.text:find("&") then
    args.text = args.text:gsub("&", "&amp;")
  elseif args.text:find("<") then
    args.text = args.text:gsub("<", "&lt;")
  elseif args.text:find(">") then
    args.text = args.text:gsub("<", "&gt;")
  end

  args.markup = args.markup or _ui.colorize(args.text or "Default text", args.color)

  if args.letter_spacing then
    args.markup = "<span letter_spacing='" .. args.letter_spacing .. "'>" .. args.markup .. "</span>"
  end

  if args.strikethrough then
    args.markup = "<span strikethrough='true'>" .. args.markup .. "</span>"
  end

  local widget = wibox.widget({
    font          = args.font,
    markup        = args.markup,
    valign        = args.valign,
    align         = args.align,
    ellipsize     = args.ellipsize,
    forced_width  = args.width,
    forced_height = args.height,
    visible       = args.visible,
    strikethrough = args.strikethrough,
    widget        = wibox.widget.textbox,
    -------
    _text         = args.text,
    _color        = args.color,
    update_text   = function(self, text)
      self._text  = text
      self.markup = _ui.colorize(text, self._color)
      if self.strikethrough then
        self.markup = "<span strikethrough='true'>"..self.markup.."</span>"
      end
    end,
    update_color  = function(self, color)
      self.markup = _ui.colorize(self._text, color)
      if self.strikethrough then
        self.markup = "<span strikethrough='true'>"..self.markup.."</span>"
      end
    end
  })

  awesome.connect_signal("theme::reload", function(lut)
    widget._color = lut[widget._color]
    widget:update_color(widget._color)
  end)

  return widget
end

function _ui.checkbox(userargs)
  local args = {
    width      = dpi(15),
    height     = dpi(15),
    checked    = true,
    shape      = _ui.rrect(dpi(2)),
    on_release = nil
  }
  gtable.crush(args, userargs or {})

  local cbox = wibox.widget({
    checked            = true,
    color              = beautiful.neutral[100],
    paddings           = dpi(1),
    forced_width       = dpi(20),
    forced_height      = dpi(20),
    shape              = _ui.rrect(dpi(1)),
    check_shape        = function(cr, width, height)
      -- TODO: Improve this. Super crusty but it works.
      local rs = math.min(width, height)
      cr:move_to((rs * 0.08) + rs/3,   (rs * 0.13) + rs/2)
      cr:line_to((rs * 0.08) + rs/9,   (rs * 0.13) + rs/4)
      cr:move_to((rs * 0.08) + rs/3,   (rs * 0.13) + rs/2)
      cr:line_to((rs * 0.08) + rs*7/9, (rs * 0.13) + rs/9)
    end,
    check_border_color = beautiful.neutral[100],
    check_color        = beautiful.neutral[100],
    check_border_width = dpi(1),
    widget             = wibox.widget.checkbox
  })

  if args.on_release then
    cbox:connect_signal("button::press", args.on_release)
  end

  return cbox
end

--- @method cborder
-- @brief Create circular border around a widget
function _ui.cborder(widget)
  local cborder = wibox.widget({
    {
      widget,
      margins = dpi(2),
      widget = wibox.container.margin,
    },
    shape  = gshape.circle,
    widget = wibox.container.background,
  })

  function cborder:update_border(color)
    self.bg = color
  end

  return cborder
end

--- @method rrborder
-- @brief Create rounded rect border around a widget
function _ui.rrborder(widget, thickness)
  local rrborder = wibox.widget({
    {
      widget,
      margins = thickness or dpi(2),
      widget = wibox.container.margin,
    },
    bg     = beautiful.neutral[800],
    shape  = _ui.rrect(),
    widget = wibox.container.background,
  })

  function rrborder:update_border(color)
    self.bg = color
  end

  rrborder:connect_signal("mouse::enter", function(self)
    self:update_border(beautiful.primary[400])
  end)

  rrborder:connect_signal("mouse::leave", function(self)
    self:update_border(beautiful.neutral[800])
  end)

  return rrborder
end

--- @method hpad
-- @brief Horizontal padding
function _ui.hpad(width)
  return wibox.widget({
    forced_width = width,
    layout = wibox.layout.fixed.horizontal,
  })
end

--- @method vpad
-- @brief Vertical padding
function _ui.vpad(height)
  return wibox.widget({
    forced_height = height,
    layout = wibox.layout.fixed.vertical,
  })
end

--- @method place
-- @brief Place + margin
function _ui.place(content, args)
  args = args or {}
  return wibox.widget({
    {
      content,
      widget = wibox.container.place,
    },
    widget = wibox.container.margin,
    margins = args.margins,
  })
end

--- @method rrect
-- @brief Create rounded rectangle
function _ui.rrect(radius)
  radius = radius or beautiful.ui_border_radius
  return function(cr, width, height)
    gshape.rounded_rect(cr, width, height, radius)
  end
end

-- █▀▄▀█ █ █▀ █▀▀
-- █░▀░█ █ ▄█ █▄▄

function _ui.dashbox_padding(content)
  return wibox.widget({
    content,
    margins = beautiful.dash_widget_gap / 2,
    widget = wibox.container.margin,
  })
end

--- @method (dashboard) dashbox_v2
-- @brief Standardized container for dashboard widgets.
function _ui.dashbox_v2(content, args)
  args = args or {}
  return wibox.widget({
    {
      {
        {
          content,
          widget = wibox.container.place,
        },
        margins = dpi(22),
        widget  = wibox.container.margin,
      },
      forced_height = args.height or nil,
      forced_width  = args.width or nil,
      bg            = beautiful.neutral[800],
      shape         = _ui.rrect(),
      widget        = wibox.container.background,
    },
    content_fill_vertical = true,
    content_fill_horizontal = true,
    widget = wibox.container.place,
  })
end

--- @method (dashboard) contentbox
-- @brief Defines layout for tabs on dashboard.
-- TODO: Rename to tablayout
function _ui.contentbox(header, content)
  local container = wibox.widget({
    header,
    {
      content,
      widget = wibox.container.place,
    },
    layout = wibox.layout.ratio.vertical,
  })
  container:adjust_ratio(1, 0, 0.08, 0.92)

  return container
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
      bg            = bg or beautiful.neutral[800],
      shape         = _ui.rrect(),
      widget        = wibox.container.background,
    },
    margins = dpi(10),
    color   = "#FF000000",
    widget  = wibox.container.margin,
  })
end

--- @method dpi
-- @brief For people with different screen resolutions, I hope this might be a solution.
-- (Sorry it took so long linuxmobile :P)
function _ui.dpi(px)
  local scale = require("cozyconf").scale
  return dpi(px * scale)
  -- return dpi(px)
end

--- @method colorize
-- @brief Apply color markup
function _ui.colorize(text, color)
  color = color or beautiful.neutral[100]
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

return _ui
