
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 
-- Displays stats for the currently selected month and week.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local area = require("modules.keynav.area")
local gears = require("gears")

local helpers = require("helpers")
local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")
local round = require("helpers.dash").round

--- list of stats that might be cool to implement
-- which weekday i work the most
-- which day of the week on average i work the most

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

--- Gets the date with the most number of hours.
-- @param data The data object.
-- @return total_hours The total hours worked this month
-- @return highest_day The date I worked the most.
-- @return highest_hours The highest number of hours I've worked per day.
local function get_stats(data)
  local highest_day = 1
  local highest_hours = 0
  local total_hours = 0

  for day = 1, #data.days do
    total_hours = total_hours + day

    if data.days[day] > highest_hours then
      highest_hours = data.days[day]
      highest_day = day
    end
  end

  return total_hours, highest_day, highest_hours
end

--- Creates the stats text ui box.
local function create_stats_ui_textbox(label_text)
  return wibox.widget({
    {
      markup = colorize(label_text, beautiful.fg),
      valign = "center",
      align = "left",
      widget = wibox.widget.textbox,
    },
    nil,
    {
      valign = "center",
      align = "right",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(50),
    forced_width = dpi(275),
    layout = wibox.layout.align.horizontal,
  })
end

------------------------------------------------

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

return function(data)
  local total_hours = create_stats_ui_textbox("Total hours worked")
  local most_hours_worked = create_stats_ui_textbox("Most hours worked")
  local highest_day = create_stats_ui_textbox("Most hours worked on")
  local avg_week = create_stats_ui_textbox("Average hours/week")

  local stats_cont = wibox.widget({
    {
      total_hours,
      highest_day,
      most_hours_worked,
      avg_week,
      spacing = dpi(12),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  data:connect_signal("timew::hours_by_day_processed", function(_)
    local total_hours_, highest_day_, highest_hours_ = get_stats(data)
    highest_day.children[2]:set_markup_silently(colorize(highest_day_, beautiful.fg_sub))
    total_hours.children[2]:set_markup_silently(colorize(total_hours_, beautiful.fg_sub))
    most_hours_worked.children[2]:set_markup_silently(colorize(highest_hours_, beautiful.fg_sub))
    avg_week.children[2]:set_markup_silently(colorize(round(total_hours_ / 7, 2), beautiful.fg_sub))
  end)

  return box(stats_cont, dpi(300), dpi(500), beautiful.dash_widget_bg)
end
