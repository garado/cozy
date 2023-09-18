
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀▀ █▀▀ █░█ █░░    █▄▄ ▀█▀ █▄░█ 
-- ▄█ ░█░ █▀█ ░█░ ██▄ █▀░ █▄█ █▄▄    █▄█ ░█░ █░▀█ 

-- Creates a button whose state can be toggled.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gtable = require("gears.table")

local stateful_btn = {}

-- gtable crush modifies target table in place
-- don't want that for this use case
local crush = function(target, source)
  local ret = {}
  for k, v in pairs(target) do ret[k] = v end
  for k, v in pairs(source) do ret[k] = v end
  return ret
end

local SELECT_PROPS = {
  bg    = beautiful.primary[700],
  bg_mo = beautiful.primary[600],
  fg    = beautiful.neutral[100],
  border_width = 0,
  border_color = beautiful.neutral[600],
}

local DESELECT_PROPS = {
  bg    = beautiful.neutral[800],
  bg_mo = beautiful.neutral[700],
  fg    = beautiful.neutral[100],
  border_width = 0,
  border_color = beautiful.neutral[600],
}

local function new(user_args)
  local ret = {}

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

  ret = wibox.widget({
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

  ret.name = args.name
  ret.func = args.func
  ret.on_press = args.on_press
  ret.select_props = crush(SELECT_PROPS, args.select or {})
  ret.deselect_props = crush(DESELECT_PROPS, args.deselect or {})

  awesome.connect_signal("theme::reload", function(lut)
    for k, _ in pairs(ret.select_props) do
      if lut[ret.select_props[k]] then
        ret.select_props[k] = lut[ret.select_props[k]] or "#bf616a"
      end
    end

    for k, _ in pairs(ret.deselect_props) do
      if lut[ret.deselect_props[k]] then
        ret.deselect_props[k] = lut[ret.deselect_props[k]] or "#bf616a"
      end
    end

    ret:update()
  end)

  function ret:get_textbox()
    return self.children[1].widget
  end

  ret:connect_signal("mouse::enter", function(self)
    self.bg = self.props.bg_mo
  end)

  ret:connect_signal("mouse::leave", function(self)
    self.bg = self.props.bg
  end)

  function ret:update()
    self.props = self.selected and self.select_props or self.deselect_props
    self.bg = self.props.bg
    -- if self.selected and self.func then self:func() end
  end

  ret:connect_signal("button::press", ret.update)

  if ret.on_press then
    ret:connect_signal("button::press", args.on_press)
  end

  ret:update()
  return ret
end

return setmetatable(stateful_btn, { __call = function(_, ...) return new(...) end })
