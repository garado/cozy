
-- █▄░█ █▀█ █░█░█ █░░ █ █▄░█ █▀▀ 
-- █░▀█ █▄█ ▀▄▀▄▀ █▄▄ █ █░▀█ ██▄ 

-- A horizontal line drawn at the current hour.

local wibox   = require("wibox")
local gcolor  = require("gears.color")
local gtable  = require("gears.table")
local calconf = require("cozyconf").calendar
local cal     = require("backend.system.calendar")
local os = os

local SECONDS_IN_HOUR = 60 * 60

local nowline = { mt = {} }

function nowline:fit(_, width, height)
  -- Take all available space
  return width, height
end

function nowline:draw(_, cr, width, height)
  -- Only draw for the current week
  if cal.weekview_cur_offset ~= 0 then return end

  cr:set_source(gcolor(calconf.nowline_color))
  cr:set_line_width(2)

  local hour_range = calconf.end_hour - calconf.start_hour + 1
  local hourline_spacing = height / hour_range

  local day_range = calconf.end_day - calconf.start_day + 1
  local dayline_spacing = width / day_range

  -- Figure out y-pos (hour)
  local now_hour = tonumber(os.date("%H")) + (tonumber(os.date("%M")) / 60)
  local y = (now_hour * hourline_spacing) - (calconf.start_hour * hourline_spacing)

  -- Figure out x-pos (day)
  local now_weekday = tonumber(os.date("%w"))
  local x = (now_weekday - calconf.start_day) * dayline_spacing

  cr:move_to(x, y)
  cr:line_to(x + dayline_spacing, y)
  cr:stroke()

  local radius = 5
  local offset = radius / 2
  cr:arc(x + radius + offset, y, radius, 0, 2*math.pi)
  cr:close_path()
  cr:fill()
end

function nowline.new(args)
  args = args or {}

  local _nowline = wibox.widget.base.make_widget()

  -- Copy methods and properties over
  gtable.crush(_nowline, nowline, true)

  -- Except those, which don't belong in the widget instance
  rawset(_nowline, "new", nil)
  rawset(_nowline, "mt", nil)

  return _nowline
end

function nowline.mt:__call(...)
  return nowline.new(...)
end

return setmetatable(nowline, nowline.mt)
