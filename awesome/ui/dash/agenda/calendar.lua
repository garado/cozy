
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Interactive calendar for viewing Timewarrior stats with heatmap to 
-- show which days I've worked the most.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local gears = require("gears")
local cal = require("core.system.cal")

local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")

-----------------------------------------------------------

-- Module-level variables
local fday
local days_in_month
local calgrid

-----------------------------------------------------------

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ ▀    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ ▄    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

--- Determines the heatmap color based on a number of events.
-- @param base    The color when heatmap is at its maximum (hottest?). This color
--                will be darkened for days that aren't as "hot".
-- @param hours   Number of hours.
local function heat(base, events)
  -- To get the right heat color, we modify the base color's lightness.
  -- The range of valid lightness values is 0 - 1.

  -- local max_events = 5
  -- if (hours > 20) then
  --   hours = max_hours
  -- end

  if events > 2 then
    local lmod = events * 0.015
    return color.pywal_lighten(base, lmod)
  else
    local lmod = events * 0.04
    return color.pywal_darken(base, lmod)
  end
end

-----------------------------------------------------------

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ ▀    █▀▀ █▀█ █▀█ █▀▀ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ ▄    █▄▄ █▄█ █▀▄ ██▄ 

--local accent = beautiful.red -- update later
local accent = beautiful.timew_cal_heatmap_accent

--- Creates SMTWTFS week labels.
local function create_week_label()
  local labels = {
    "S", "M", "T", "W", "T", "F", "S"
  }

  local week_label_cont = wibox.widget ({
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal,
  })

  for i = 1, 7, 1 do
    local label = wibox.widget({
      markup    = colorize(labels[i], beautiful.fg),
      font      = beautiful.font_name .. "11",
      forced_width = dpi(35),
      align     = "center",
      valign    = "center",
      widget    = wibox.widget.textbox,
    })
    week_label_cont:add(label)
  end

  return week_label_cont
end

--- Create wibox for a single day of the calendar.
-- @param date    The date (1-31)
-- @param valid   Whether it's a day within this month or not
local function _create_day(date, valid)
  local cnt = cal:get_num_events(os.date("%m"), date)
  local heat_color = (valid and cnt > 0) and heat(accent, cnt) or nil

  local fg = valid > 0 and beautiful.fg or beautiful.fg_sub

  local day = wibox.widget({
    {
      -- Date
      markup  = colorize(date, fg),
      font    = beautiful.font_name .. "12",
      align   = "center",
      valign  = "center",
      widget  = wibox.widget.textbox,
    },
    -- Heatmap background color
    bg = heat_color,
    forced_width  = dpi(35),
    forced_height = dpi(35),
    shape = gears.shape.circle,
    widget = wibox.container.background,
  })
  return day
end

--- Create a widget containing all of the days within a calendar.
-- @param month   The month (as an integer).
-- @param year    The year.
local function create_month_widget(month, year)

  -- Get number of days in the month.
  local _days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  days_in_month = _days_in_month[tonumber(os.date("%m"))]

  -- The calendar is laid out as a grid.
  calgrid = wibox.widget({
    forced_num_cols = 7,
    forced_num_rows = 4,
    orientation = "vertical",
    spacing = dpi(20),
    homogeneous = true,
    layout = wibox.layout.grid,
  })

  -- Get date of first day of the month.
  -- This is a number 0-6 (Sunday - Saturday)
  fday = os.date("%w", os.time{ year=year, month=month, day=1, hour=0, sec=0})

  -- If the first day of the month doesn't start on Sunday, then we should
  -- backfill with days from last month
  if fday ~= 0 then
    local days_in_last_month = _days_in_month[tonumber(os.date("%m")) - 1]
    for i = fday - 1, 0, -1 do
      local backfilled_date = days_in_last_month - i
      local day = _create_day(backfilled_date, -1)
      calgrid:add(day)
    end
  end

  for i = 1, days_in_month do
    local day = _create_day(i, 1)
    calgrid:add(day)
  end

  return wibox.widget({
    calgrid,
    widget = wibox.container.constraint,
  })
end

-----------------------------------------------------------

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- Putting all of the wiboxes together.

-- Get this month and year
local _thismonth = os.date("%m")
local _thisyear = os.date("%Y")

local month_label = wibox.widget({
  markup  = colorize(os.date("%B %Y"), beautiful.fg),
  font    = beautiful.font_name .. "17",
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textbox,
})

local calendar = wibox.widget({
  {
    {
      month_label,
      create_week_label(),
      spacing = dpi(20),
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(20),
    widget = wibox.container.margin,
  },
  widget = wibox.container.constraint,
})

local _calendar = box(calendar, dpi(450), dpi(420), beautiful.dash_widget_bg)

cal:connect_signal("ready::month_events", function()
  local month = create_month_widget(_thismonth, _thisyear)
  local ugh = calendar.children[1].children[1]
  ugh:add(month)
end)

return _calendar
