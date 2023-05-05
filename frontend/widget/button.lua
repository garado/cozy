
-- █▄▄ █░█ ▀█▀ ▀█▀ █▀█ █▄░█ 
-- █▄█ █▄█ ░█░ ░█░ █▄█ █░▀█ 

-- A simple stateless button with my preferred defaults.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gtable = require("gears.table")

local button = {}

local function worker(user_args)
  local args = {
    bg      = beautiful.neutral[800],
    bg_mo   = beautiful.neutral[700],
    fg      = beautiful.fg,
    fg_mo   = beautiful.fg,
    align   = "left",
    text    = "Default",
    shape   = ui.rrect(),
    margins = dpi(12),
    width   = nil,
    height  = nil,
    func    = nil,
    border_width = 0,
    border_color = beautiful.neutral[600],
  }
  gtable.crush(args, user_args)

  local btn = wibox.widget({
    {
      ui.textbox({
        font   = args.font,
        markup = args.markup,
        text   = args.text,
        color  = args.fg,
        align  = args.align,
      }),
      margins = args.margins,
      widget  = wibox.container.margin,
    },
    bg    = args.bg,
    shape = ui.rrect(),
    forced_width  = args.width,
    forced_height = args.height,
    border_width  = args.border_width,
    border_color  = args.border_color,
    widget        = wibox.container.background,
  })

  btn.props = {
    bg    = args.bg,
    bg_mo = args.bg_mo,
    fg    = args.fg,
    fg_mo = args.fg_mo,
    func  = args.func
  }

  btn:connect_signal("mouse::enter", function(self)
    btn.bg = self.props.bg_mo
  end)

  btn:connect_signal("mouse::leave", function(self)
    btn.bg = self.props.bg
  end)

  btn:connect_signal("button::press", function(self)
    if self.props.func then self.props.func() end
  end)

  return btn
end

return setmetatable(button, { __call = function(_, ...) return worker(...) end })
