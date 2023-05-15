
-- █▀▀ █▀█ █ █▀▄ █░░ █ █▄░█ █▀▀ █▀ 
-- █▄█ █▀▄ █ █▄▀ █▄▄ █ █░▀█ ██▄ ▄█ 

local wibox = require("wibox")
local gcolor = require("gears.color")
local gtable = require("gears.table")
local calconf = require("cozyconf").calendar
local dash  = require("backend.cozy.dash")
local beautiful = require("beautiful")

local gridlines = { mt = {} }

local signal_sent = false
local w, h

function gridlines:fit(_, width, height)
  -- Take all available space
  return width, height
end

function gridlines:draw(_, cr, width, height)
  cr:set_source(gcolor(beautiful.neutral[800]))
  cr:set_line_width(1)

  -- Draw horizontal lines (to separate hours)
  local hour_range = calconf.end_hour - calconf.start_hour + 1
  local hourline_spacing = height / hour_range
  local y = 0
  cr:move_to(0, 0)
  for _ = 1, hour_range do
    cr:line_to(width, y)
    y = y + hourline_spacing
    cr:move_to(0, y)
  end

  -- Draw vertical lines (to separate days)
  local day_range = calconf.end_day - calconf.start_day + 1
  local dayline_spacing = width / day_range
  local x = 0
  cr:move_to(0, 0)
  for _ = calconf.start_day, calconf.end_day do
    cr:line_to(x, height)
    x = x + dayline_spacing
    cr:move_to(x, 0)
  end

  cr:stroke()

  -- The hour and day labels require the height and width from this widget
  -- to render properly. Only send it once.
  if (not signal_sent) or (signal_sent and (w ~= width or h ~= height)) then
    w = width
    h = height
    dash.weekview_h = height
    dash.weekview_w = width
    dash:emit_signal("weekview::size_calculated", height, width)
    signal_sent = true
  end
end

function gridlines.new(args)
  args = args or {}

  local _gridlines = wibox.widget.base.make_widget()

  -- Copy methods and properties over
  gtable.crush(_gridlines, gridlines, true)

  -- Except those, which don't belong in the widget instance
  rawset(_gridlines, "new", nil)
  rawset(_gridlines, "mt", nil)

  return _gridlines
end

function gridlines.mt:__call(...)
  return gridlines.new(...)
end

return setmetatable(gridlines, gridlines.mt)
