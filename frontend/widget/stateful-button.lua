
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀▀ █▀▀ █░█ █░░    █▄▄ ▀█▀ █▄░█ 
-- ▄█ ░█░ █▀█ ░█░ ██▄ █▀░ █▄█ █▄▄    █▄█ ░█░ █░▀█ 

-- Creates a button whose state can be toggled.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gtable = require("gears.table")

local stateful_btn = {}

local SELECT_PROPS = {
  bg    = beautiful.primary[700],
  bg_mo = beautiful.primary[600],
  fg    = beautiful.neutral[100],
  fg_mo = nil,
  border_width = 0,
  border_color = beautiful.neutral[600],
}

local DESELECT_PROPS = {
  bg    = beautiful.neutral[800],
  bg_mo = beautiful.neutral[700],
  fg    = beautiful.neutral[100],
  fg_mo = nil,
  border_width = 0,
  border_color = beautiful.neutral[600],
}

awesome.connect_signal("theme::reload", function(lut)
  SELECT_PROPS.bg    = lut[SELECT_PROPS.bg]
  SELECT_PROPS.bg_mo = lut[SELECT_PROPS.bg_mo]
  SELECT_PROPS.fg    = lut[SELECT_PROPS.fg]
  SELECT_PROPS.fg_mo = lut[SELECT_PROPS.fg_mo]
  SELECT_PROPS.border_color = lut[SELECT_PROPS.border_color]
  DESELECT_PROPS.bg    = lut[DESELECT_PROPS.bg]
  DESELECT_PROPS.bg_mo = lut[DESELECT_PROPS.bg_mo]
  DESELECT_PROPS.fg    = lut[DESELECT_PROPS.fg]
  DESELECT_PROPS.fg_mo = lut[DESELECT_PROPS.fg_mo]
  DESELECT_PROPS.border_color = lut[DESELECT_PROPS.border_color]
end)

local function worker(user_args)
  local args = {
    text     = "Default",
    shape    = ui.rrect(),
    margins  = dpi(12),
    width    = nil,
    height   = nil,
    name     = nil,
    selected = false,
    func     = nil, -- TODO: Replace func with on_press
    on_press = nil,
  }
  gtable.crush(args, user_args)
  if args.set_no_shape then args.shape = nil end

  stateful_btn = wibox.widget({
    {
      ui.textbox({
        text = args.text,
        font = args.font,
        align = "center",
        markup = args.markup,
        color = args.fg,
      }),
      margins = args.margins,
      widget  = wibox.container.margin,
    },
    shape = args.shape,
    forced_width  = args.width,
    forced_height = args.height,
    widget = wibox.container.background,
  })

  stateful_btn.name = args.name
  stateful_btn.func = args.func
  stateful_btn.on_press = args.on_press

  function stateful_btn:get_textbox()
    return self.children[1].widget
  end

  stateful_btn:connect_signal("mouse::enter", function(self)
    self.bg = self.props.bg_mo
  end)

  stateful_btn:connect_signal("mouse::leave", function(self)
    self.bg = self.props.bg
  end)

  function stateful_btn:update()
    self.props = self.selected and SELECT_PROPS or DESELECT_PROPS
    self.bg = self.props.bg
    if self.selected and self.func then self:func() end
  end

  stateful_btn:connect_signal("button::press", stateful_btn.update)

  if stateful_btn.on_press then
    stateful_btn:connect_signal("button::press", args.on_press)
  end

  awesome.connect_signal("theme::reload", function()
    stateful_btn:update()
  end)

  stateful_btn:update()
  return stateful_btn
end

return setmetatable(stateful_btn, { __call = function(_, ...) return worker(...) end })
