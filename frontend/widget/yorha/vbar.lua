
-- █░█ █▀▀ █▀█ ▀█▀ █ █▀▀ ▄▀█ █░░    █▄▄ ▄▀█ █▀█    ▀█▀ █░█ █ █▄░█ █▀▀
-- ▀▄▀ ██▄ █▀▄ ░█░ █ █▄▄ █▀█ █▄▄    █▄█ █▀█ █▀▄    ░█░ █▀█ █ █░▀█ █▄█

local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local gtable    = require("gears.table")

local vbar      = { mt = {} }

local defaults  = {
  color = beautiful.neutral[100]
}

function vbar:fit(_, width, height)
  return 40, self._private.height
end

function vbar:draw(_, cr, width, height)
  cr:set_source(gears.color(self._private.color))

  -- thicc
  cr:set_line_width(30)
  cr:move_to(0, 0)
  cr:line_to(0, height)
  cr:stroke()

  -- thin
  cr:set_line_width(3)
  cr:move_to(22, 0)
  cr:line_to(22, height)
  cr:stroke()
end

function vbar.new(args)
  args = args or {}

  local _vbar = wibox.widget.base.make_widget()

  -- Set initial values for properties.
  gtable.crush(_vbar._private, defaults, true)
  gtable.crush(_vbar._private, args, true)
  _vbar.id = args.id

  -- Copy methods and properties over
  gtable.crush(_vbar, vbar, true)

  -- Except those, which don't belong in the widget instance
  rawset(_vbar, "new", nil)
  rawset(_vbar, "mt", nil)

  return _vbar
end

function vbar.mt:__call(...)
  local g = vbar.new(...)

  -- awesome.connect_signal("theme::reload", function(lut)
  --   g._private.avg_color = lut[g._private.avg_color]
  --   for i = 1, #g._private.colors do
  --     g._private.colors[i] = lut[g._private.colors[i]]
  --   end
  -- end)

  return g
end

return setmetatable(vbar, vbar.mt)
