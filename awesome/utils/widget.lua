
-- Wrappers for common widgets

local wibox = require("wibox")
local beautiful = require("beautiful")

local _widget = {}

function _widget.colorize(text, color)
  color = color or "#FF000000"
	return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

--- Create textbox with my preferred defaults.
function _widget.textbox(args)
  return wibox.widget.textbox({
    markup = args.markup or _widget.colorize("", beautiful.primary_0),
    valign = args.valign or "center",
    align  = args.align  or "center",
    font   = args.font   or beautiful.font_reg_xs,
    widget = wibox.widget.textbox,
  })
end

return _widget
