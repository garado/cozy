
-- ▀█▀ █▀█ █ ▄▀█ █▄░█ █▀▀ █░░ █▀▀    ▀█▀ █░█ █ █▄░█ █▀▀ 
-- ░█░ █▀▄ █ █▀█ █░▀█ █▄█ █▄▄ ██▄    ░█░ █▀█ █ █░▀█ █▄█ 

local beautiful  = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local gtable = require("gears.table")

local triangles = { mt = {} }

local defaults = {
  color = beautiful.neutral[100]
}

function triangles:fit(_, width, height)
  return width, height
end

function triangles:draw(_, cr, width, height)
  cr:set_source(gears.color(beautiful.neutral[100]))
  cr:set_line_width(5)

  -- left
  cr:move_to(0, 0)
  cr:line_to(10, 0)
  cr:stroke()

  local x = 10

  while x < width - 60 do
    -- top left dot
    x = x + 15
    cr:arc(x, 8, 3, 0, 20)
    cr:fill()

    -- middle dot
    x = x + 10
    cr:arc(x, 16, 3, 0, 20)
    cr:fill()

    -- top right dot
    x = x + 10
    cr:arc(x, 8, 3, 0, 20)
    cr:fill()

    -- line
    x = x + 15
    cr:move_to(x, 0)
    x = x + 10
    cr:line_to(x, 0)
    cr:stroke()
  end
end

function triangles.new(args)
  args = args or {}

  local _triangles = wibox.widget.base.make_widget()

  -- Set initial values for properties.
  gtable.crush(_triangles._private, defaults, true)
  gtable.crush(_triangles._private, args, true)
  _triangles.id = args.id

  -- Copy methods and properties over
  gtable.crush(_triangles, triangles, true)

  -- Except those, which don't belong in the widget instance
  rawset(_triangles, "new", nil)
  rawset(_triangles, "mt", nil)

  return _triangles
end

function triangles.mt:__call(...)
  local g = triangles.new(...)

  -- awesome.connect_signal("theme::reload", function(lut)
  --   g._private.avg_color = lut[g._private.avg_color]
  --   for i = 1, #g._private.colors do
  --     g._private.colors[i] = lut[g._private.colors[i]]
  --   end
  -- end)

  return g
end

return setmetatable(triangles, triangles.mt)
