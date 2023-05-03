
-- █░░ █ █▄░█ █▀▀ █▀▀ █▀█ ▄▀█ █▀█ █░█ 
-- █▄▄ █ █░▀█ ██▄ █▄█ █▀▄ █▀█ █▀▀ █▀█ 

-- Based on psychon's work
-- https://github.com/awesomeWM/awesome/issues/2899#issuecomment-540487182

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gtable = require("gears.table")

local linegraph = { mt = {} }

-- Default properties
local prop_defaults = {
  autoscale = false,
  legend = false,
  min_value = 0,
  max_value = 1,
  colors = { beautiful.primary[400], beautiful.primary[200] },
  data = {},
}

function linegraph:add_data(data)
  local len = #data
  if self._private.len and self._private.len ~= len then
    error()
  end
  self._private.len = len
  table.insert(self._private.data, data)
  self:emit_signal("widget::redraw_needed")
end

function linegraph:fit(_, width, height)
  -- Take all available space
  return width, height
end

function linegraph:draw(_, cr, width, height)
  local data = self._private.data
  local colors = self._private.colors

  -- Ensure we have at least two points of data
  if #data == 0 then
    return
  end
  if #data == 1 then
    data = { data[1], data[1] }
  end

  -- Scale things so that we have less coordinate values to shuffle
  local xscale = width / (#data - 1)
  local yscale = height / (self._private.max_value - self._private.min_value)

  local sum = 0
  local fuck = self._private.data[1]
  for i = 1, #fuck do
    sum = sum + fuck[i]
  end
  local avg = sum / #fuck

  local clr = beautiful.neutral[600]
  cr:set_source(gears.color(clr))
  cr:move_to(0, avg * yscale)
  cr:line_to(9 * xscale, avg * yscale)
  cr: stroke()

  -- Now, actually draw things
  for line = 1, self._private.len do
    local color = colors[(line - 1) % #colors + 1]
    cr:set_source(gears.color(color))
    for i = 1, #data do
      cr:line_to((i - 1) * xscale, data[i][line] * yscale)
    end
    cr:stroke()
  end
end

function linegraph.new(args)
  args = args or {}

  local _linegraph = wibox.widget.base.make_widget()

  -- Set initial values for properties.
  gtable.crush(_linegraph._private, prop_defaults, true)
  gtable.crush(_linegraph._private, args, true)
  _linegraph.id = args.id
  _linegraph._private.values    = {}

  -- Copy methods and properties over
  gtable.crush(_linegraph, linegraph, true)

  -- Except those, which don't belong in the widget instance
  rawset(_linegraph, "new", nil)
  rawset(_linegraph, "mt", nil)

  return _linegraph
end

function linegraph.mt:__call(...)
    return linegraph.new(...)
end

return setmetatable(linegraph, linegraph.mt)
