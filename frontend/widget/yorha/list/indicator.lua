
-- █ █▄░█ █▀▄ █ █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █ █░▀█ █▄▀ █ █▄▄ █▀█ ░█░ █▄█ █▀▄ 

local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local gtable    = require("gears.table")

local vbar      = { mt = {} }

local defaults  = {
  color = beautiful.neutral[100],
  alt_color = beautiful.neutral[900],
  height = 20,
  width  = 30,
}

function vbar:fit(_, width, height)
  return self._private.width, self._private.height
end

function vbar:draw(_, cr, width, height)
  cr:set_source(gears.color(self._private.color))

  local w = self._private.width
  local h = self._private.height

  local tri_start_y = h / 5
  local tri_end_y   = tri_start_y * 4
  local xl = w / 4
  local xr = w

  local dot_radius = 1.5

  -- little shape
  cr:move_to(0, h/2) -- leftmost point
  cr:line_to(xl, tri_end_y) -- bottom point
  cr:line_to(xr, h/2) -- rightmost point
  cr:line_to(xl, tri_start_y) -- topmost point
  cr:fill()

  -- top right dot
  cr:arc(self._private.width - dot_radius, dot_radius, dot_radius, 0, 360)
  cr:fill()

  -- bottom right dot
  cr:arc(self._private.width - dot_radius, self._private.height - dot_radius, dot_radius, 0, 360)
  cr:fill()

  -- dot in the little shape
  cr:set_source(gears.color(self._private.alt_color))
  cr:arc(w/4, h/2, dot_radius, 0, 360)
  cr:fill()

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
