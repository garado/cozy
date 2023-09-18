
-- █░░ ▄▀█ █▄▄ █▀▀ █░░ █▀ 
-- █▄▄ █▀█ █▄█ ██▄ █▄▄ ▄█ 

-- Labels for days and hours.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local wibox = require("wibox")
local calconf = require("cozyconf").calendar
local dash  = require("backend.cozy").dash
local cal   = require("backend.system.calendar")
local os = os

-- #defines
local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY  = 24 * SECONDS_IN_HOUR
local HOURLABEL_START_OFFSET = cal.start_hour * SECONDS_IN_HOUR

local function gen_hourlabel(hour, height)
  return ui.textbox({
    text  = os.date("%I%p", (hour * SECONDS_IN_HOUR) + HOURLABEL_START_OFFSET),
    align = "right",
    font  = beautiful.font_reg_s,
    color = beautiful.neutral[500],
    height = height,
  })
end

local hourlabels = wibox.widget({
  layout = wibox.layout.manual,
})

local function update_hourlabels()
  hourlabels:reset()
  if not dash.weekview_h or not dash.weekview_w then return end
  local hour_spacing = dash.weekview_h / (cal.end_hour - cal.start_hour + 1)
  local y = (dash.weekview_h * 0.08 / 2) + 8 -- off by a little bit for some reason
  for i = cal.start_hour, cal.end_hour do
    hourlabels:add_at(gen_hourlabel(i, hour_spacing), { x = 0, y = y })
    y = y + hour_spacing
  end
end

------------

local function gen_daylabel(width, ts)
  local color = beautiful.neutral[200]

  -- Today gets a special color
  if os.date("%d", ts) == os.date("%d") and cal.weekview_cur_offset == 0 then
    color = beautiful.primary[400]
  end

  return wibox.widget({
    ui.textbox({
      text = os.date("%d", ts),
      align = "center",
      font = beautiful.font_med_m,
      color = color,
    }),
    ui.textbox({
      text  = os.date("%a", ts),
      align = "center",
      font  = beautiful.font_med_s,
      color = color,
    }),
    forced_width = width,
    layout = wibox.layout.fixed.vertical,
  })
end

local daylabels = wibox.widget({
  layout = wibox.layout.manual,
})

local function update_daylabels()
  daylabels:reset()
  if not dash.weekview_h or not dash.weekview_w then return end

  -- Figure out timestamp for start day using today's date
  local now = os.time()
  local weekday_today = os.date("%w")
  local ts = now - (weekday_today * SECONDS_IN_DAY) + cal.weekview_cur_offset

  local num_days = 7
  local day_spacing = dash.weekview_w / num_days
  local x = 0
  for _ = 0, 7 do
    daylabels:add_at(gen_daylabel(day_spacing, ts), { x = x, y = 0 })
    x = x + day_spacing
    ts = ts + SECONDS_IN_DAY
  end
end

-- Hour labels and day labels need the width, height to calculate the position of the widgets.
-- Since the labels are attached to the top/sides of the gridlines, we can just use the gridline's
-- height and width, which we obtain from a signal emitted the first time gridline:draw is run.
-- (Wasn't sure how else to get the height/width.)
dash:connect_signal("weekview::size_calculated", function(_)
  update_hourlabels()
  update_daylabels()
end)

dash:connect_signal("date::changed", update_daylabels)
cal:connect_signal("weekview::change_week", update_daylabels)
cal:connect_signal("hours::adjust", update_hourlabels)

return function()
  return hourlabels, daylabels
end
