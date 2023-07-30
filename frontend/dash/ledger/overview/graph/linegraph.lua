
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
  max_value = 100,
  autoset_max = true,
  autoset_min = true,
  show_average = true,
  avg_color = beautiful.neutral[600],
  colors = { beautiful.primary[400] },
  data = {},
}

function linegraph:add_data(data)
  local len = #data
  if self._private.len and self._private.len ~= len then
    print('Linegraph error: Incorrect length')
  end
  self._private.len = len
  table.insert(self._private.data, data)

  if self._private.autoset_max then
    for i = 1, #data do
      if data[i] > self._private.max_value then
        self._private.max_value = data[i] + 100
      end
    end
  end

  if self._private.autoset_min then
    for i = 1, #data do
      if data[i] < self._private.min_value then
        self._private.min_value = data[i] - 100
      end
    end
  end

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

  -- Calculate the average
  -- NOTE: This only works for the first dataset!
  if self._private.show_average then
    local sum = 0
    for i = 1, #data do
      sum = sum + data[i][1]
    end
    local avg = sum / #data

    local clr = self._private.avg_color
    cr:set_source(gears.color(clr))
    cr:move_to(0, avg * yscale)
    cr:line_to(width, avg * yscale)
    cr: stroke()
  end

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
