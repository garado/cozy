
-- █░░ ▄▀█ █▄▄ █▀▀ █░░ █▀ 
-- █▄▄ █▀█ █▄█ ██▄ █▄▄ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local calconf = require("cozyconf").calendar
local dash  = require("backend.state.dash")
local os = os

local SECONDS_IN_HOUR = 60 * 60
local SECONDS_IN_DAY  = 24 * SECONDS_IN_HOUR
local HOURLABEL_START_OFFSET = calconf.start_hour * SECONDS_IN_HOUR

local today = os.date("%d")

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
  ------
  init = function(self, height)
    local hour_spacing = height / (calconf.end_hour - calconf.start_hour + 1)
    local y = (height * 0.08) + 3 -- off by a little bit for some reason
    for i = calconf.start_hour, calconf.end_hour do
      self:add_at(gen_hourlabel(i, hour_spacing), { x = 0, y = y })
      y = y + hour_spacing
    end
  end
})

------------

local function gen_daylabel(day, width, ts)
  local color = beautiful.neutral[200]

  -- Today gets a special color
  if os.date("%d", ts) == today then
    color = beautiful.primary[400]
  end

  return wibox.widget({
    ui.textbox({
      text = os.date("%d", ts),
      font = beautiful.font_med_m,
      color = color,
    }),
    ui.textbox({
      text  = os.date("%a", ts),
      font  = beautiful.font_med_s,
      color = color,
    }),
    forced_width = width,
    layout = wibox.layout.fixed.vertical,
  })
end

local daylabels = wibox.widget({
  layout = wibox.layout.manual,
  ------
  init = function(self, width)
    -- Figure out timestamp for start day using today's date
    local now = os.time()
    local weekday_today = os.date("%w")
    local ts = now - (weekday_today * SECONDS_IN_DAY)

    local day_spacing = width / (calconf.end_day - calconf.start_day + 1)
    local x = 0
    for i = calconf.start_day, calconf.end_day do
      self:add_at(gen_daylabel(i, day_spacing, ts), { x = x, y = 0 })
      x = x + day_spacing
      ts = ts + SECONDS_IN_DAY
    end
  end
})

-- Hour labels and day labels need the width, height to calculate the position of the widgets.
-- Since the labels are attached to the top/sides of the gridlines, we can just use the gridline's
-- height and width, which we obtain from a signal emitted the first time gridline:draw is run.
-- (Wasn't sure how else to get the height/width.)
dash:connect_signal("weekview::size_calculated", function(_, height, width)
  hourlabels:init(height)
  daylabels:init(width)
end)

return function()
  return hourlabels, daylabels
end
