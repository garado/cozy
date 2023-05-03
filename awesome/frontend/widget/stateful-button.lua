
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀▀ █▀▀ █░█ █░░    █▄▄ ▀█▀ █▄░█ 
-- ▄█ ░█░ █▀█ ░█░ ██▄ █▀░ █▄█ █▄▄    █▄█ ░█░ █░▀█ 

-- Creates a button whose state can be toggled.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")

local stateful_btn = {}

local function worker(user_args)
  local args = {
    text     = "Default",
    shape    = ui.rrect(),
    margins  = dpi(12),
    width    = nil,
    height   = nil,
    name     = nil,
    selected = false,

    select = {
      bg    = beautiful.primary[700],
      bg_mo = beautiful.primary[600],
      fg    = beautiful.fg,
      fg_mo = nil,
      border_width = 0,
      border_color = beautiful.neutral[600],
      funcs = {},
    },

    deselect = {
      bg    = beautiful.neutral[800],
      bg_mo = beautiful.neutral[700],
      fg    = beautiful.fg,
      fg_mo = nil,
      border_width = 0,
      border_color = beautiful.neutral[600],
      funcs = {},
    },
  }
  gtable.crush(args, user_args)

  stateful_btn = wibox.widget({
    {
      ui.textbox({
        text = args.text,
        font = args.font,
        markup = args.markup,
        color = args.fg,
      }),
      margins = args.margins,
      widget  = wibox.container.margin,
    },
    widget = wibox.container.background,
  })

  stateful_btn.name = args.name
  stateful_btn.select_props = args.select
  stateful_btn.deselect_props = args.deselect

  function stateful_btn:get_textbox()
    return self.children[1].widget
  end

  stateful_btn:connect_signal("mouse::enter", function(self)
    self.bg = self.props.bg_mo
  end)

  stateful_btn:connect_signal("mouse::leave", function(self)
    self.bg = self.props.bg
  end)

  local press_function = args.press_func or function(self)
    self.selected = not self.selected
    self:update()
  end
  stateful_btn:connect_signal("button::press", press_function)

  function stateful_btn:update()
    local props = self.selected and self.select_props or self.deselect_props
    self.props = props

    self.bg = props.bg

    for i = 1, #self.props.funcs do
      self.props.funcs[i]()
    end
  end

  stateful_btn:update()
  return stateful_btn
end

return setmetatable(stateful_btn, { __call = function(_, ...) return worker(...) end })
