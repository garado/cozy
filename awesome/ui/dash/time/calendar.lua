
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Interactive calendar for viewing Timewarrior stats with heatmap to 
-- show which days I've worked the most.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local awful = require("awful")
local area = require("modules.keynav.area")
local gears = require("gears")

local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")
local datestr_to_ts = require("helpers.dash").datestr_to_ts

-----------------------------------------------------------

-- Module-level variables
local fday
local days_in_month
local calgrid

-----------------------------------------------------------

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ ▀    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ ▄    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

--- Determines the heatmap color based on a number of hours.
-- @param base    The color when heatmap is at its maximum (hottest?). This color
--                will be darkened for days that aren't as "hot".
-- @param hours   Number of hours.
local function heat(base, hours)
  -- To get the right heat color, we modify the base color's lightness.
  -- The range of valid lightness values is 0 - 1.

  local max_hours = 20
  if (hours > 20) then
    hours = max_hours
  end

  if hours > 6 then
    local lmod = (max_hours - hours) * 0.015
    return color.pywal_lighten(base, lmod)
  else
    local lmod = (max_hours - hours) * 0.04
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
-- @param valid   The number of hours worked on this day
local function _create_day(date, valid)
  -- local heat_color
  -- if hours > 0 then
  --   heat_color = heat(accent, hours)
  -- end

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
    -- bg = heat_color,
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

return function(data)
  -- Get this month and year
  local _thismonth = os.date("%m")
  local _thisyear = os.date("%Y")
  local month = create_month_widget(_thismonth, _thisyear)

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
        month,
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(20),
      widget = wibox.container.margin,
    },
    widget = wibox.container.constraint,
  })

  calendar = box(calendar, dpi(450), dpi(420), beautiful.dash_widget_bg)

  -- Once the json is ready we can update the heatmap
  -- Loop through every entry and count the hours worked per day
  -- Kind of ugly but it works lol
  data:connect_signal("timew::json_processed", function(_)
    -- Find the first date
    local first_ts  = datestr_to_ts(data.entry[1]["start"])
    local last_date = tonumber(os.date("%d", first_ts)) or 0
    local hours_this_date = 0

    for i in ipairs(data.entry) do
      local ts = datestr_to_ts(data.entry[i]["start"])
      local this_date = tonumber(os.date("%d", ts)) or 0

      -- The date is different, which means we finished processing all 
      -- the entries from the last day, so we can update the heatmap for
      -- the last day
      if this_date ~= last_date or i == data.num_entries then
        local grid_item = calgrid.children[fday + last_date]
        local this_heat = heat(beautiful.timew_cal_heatmap_accent, hours_this_date)
        grid_item.bg = this_heat

        -- for other modules to keep track of hours by date 
        data.days[last_date] = hours_this_date

        -- Add tooltip showing hours
        -- BUG: hours always show as 0 in tooltip despite printing fine above
        -- local tooltip = awful.tooltip{}
        -- tooltip:add_to_object(grid_item)

        -- grid_item:connect_signal("mouse::enter", function()
        --   tooltip.text = tostring(hours_this_date) .. "h"
        -- end)

        last_date = this_date
        hours_this_date = 0
      end

      -- Update hours this date
      hours_this_date = hours_this_date + (data.entry[i]["duration"] or 0)
    end

    data:emit_signal("timew::hours_by_day_processed")
  end)

  return calendar
end
