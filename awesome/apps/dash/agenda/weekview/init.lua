
-- █░█░█ █▀▀ █▀▀ █▄▀ █░█ █ █▀▀ █░█░█ 
-- ▀▄▀▄▀ ██▄ ██▄ █░█ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- A fancier redesign of the calendar!
-- Sadly this does not currently support scrolling up or down
-- to view hours outside the displayed time range.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local keynav = require("modules.keynav")
local cal  = require("core.system.cal")
local dash = require("core.cozy.dash")
local ui    = require("helpers.ui")
local core  = require("helpers.core")
local config = require("cozyconf")

local nav_weekview = keynav.area({
  name      = "nav_weekview",
  circular  = true,
})

-- Module-level variables 

-- TODO: make these config options
local DAYS_TO_DISPLAY = 7
local START_HOUR  = 8
local END_HOUR    = 22

local HOUR_HEIGHT      = dpi(45)  -- Height of an hour row
local HOUR_LABEL_WIDTH = dpi(70)

local DAYCOL_SPACING = dpi(6)
local DAYCOL_HEADER_HEIGHT = dpi(40)
local DAYCOL_GRIDLINE_MARGIN = dpi(10)
local DAYCOL_HEIGHT  = HOUR_HEIGHT * (END_HOUR - START_HOUR)
local DAYCOL_WIDTH   = dpi(165) -- Width of a day column

local EVENTBOX_WIDTH = DAYCOL_WIDTH - dpi(10)
local EVENTBOX_VERT_MARGIN = dpi(2)

local SECONDS_IN_DAY = 24 * 60 * 60

local OVERLAP_X_ADJUST = dpi(7)
local OVERLAP_BG = {
  beautiful.bg_2,
  beautiful.bg_3,
  beautiful.bg_4,
  beautiful.bg_5,
}

local nowline_x_offset = 0

-- █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

-- Calculate the y position for an event given its start time
-- @param start_time A floating point number 0-23.99
local function calc_y_pos(start_time)
  return (start_time - START_HOUR) * HOUR_HEIGHT
end

-- Calculate the height of an event given its start time and end time
-- @param start_time  A floating point number 0-23.99
-- @param end_time    A floating point number 0-23.99
local function calc_event_height(start_time, end_time)
  return ((end_time - start_time) * HOUR_HEIGHT) - EVENTBOX_VERT_MARGIN
end

--- Convert a time string HH:MM to an integer 0-23.99.
local function timestr_to_int(timestr)
  local fields = core.split(":", timestr)
  local h = tonumber(fields[1])
  local m = tonumber(fields[2]) / 60
  return h + m
end

-- Convert date from gcalcli (YYYY-MM-DD) to a timestamp
-- @return os.time timestamp
local function date_to_int(date)
  local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
  local xyear, xmon, xday = date:match(pattern)
  return os.time({
    year = xyear, month = xmon, day = xday,
    hour = 0, min = 0, sec = 0})
end


-- █░█ █ ▀    █▀▄▀█ █ █▀ █▀▀ 
-- █▄█ █ ▄    █░▀░█ █ ▄█ █▄▄ 

-- Vertical hour labels on left side
local ui_timelabels = wibox.widget({
  forced_width = HOUR_LABEL_WIDTH,
  layout = wibox.layout.fixed.vertical,
  -----
  init = function(self)
    self:reset()

    -- Create hour labels
    for i = START_HOUR, END_HOUR - 1, 1 do
      local time = string.format("%02d", i) .. ":00"
      local timelabel = wibox.widget({
        forced_height = HOUR_HEIGHT,
        markup = ui.colorize(time, beautiful.fg_2),
        valign = "top",
        align  = "center",
        font   = beautiful.font_reg_s,
        widget = wibox.widget.textbox,
      })
      self:add(timelabel)
    end
  end,
})

-- Underlying gridlines
local ui_gridlines = wibox.widget({
  forced_height = HOUR_HEIGHT * END_HOUR - START_HOUR,
  forced_width  = HOUR_LABEL_WIDTH + (DAYS_TO_DISPLAY * DAYCOL_WIDTH),
  layout = wibox.layout.manual,
  -----
  init = function(self)
    -- Add horizontal gridlines
    for i = START_HOUR, END_HOUR, 1 do
      local line = self.horizontal_gridline()
      line.point.y = calc_y_pos(i)
      self:add(line)
    end

    -- Add vertical gridlines
    for i = 1, DAYS_TO_DISPLAY, 1 do
      local line = self.vertical_gridline()
      line.point.x = (i * DAYCOL_WIDTH) + (i * DAYCOL_SPACING)
      self:add(line)
    end
  end,

  horizontal_gridline = function()
    return wibox.widget({
      bg = beautiful.bg_1,
      forced_height = dpi(1),
      forced_width  = HOUR_LABEL_WIDTH + (DAYS_TO_DISPLAY * DAYCOL_WIDTH),
      widget = wibox.container.background,
      point = { x = 0, y = 0 },
    })
  end,

  vertical_gridline = function()
    return wibox.widget({
      bg = beautiful.bg_1,
      forced_height = HOUR_HEIGHT * (END_HOUR - START_HOUR),
      forced_width  = dpi(1),
      widget = wibox.container.background,
      point = { x = 0, y = 0 },
    })
  end
})

-- A horizontal line at the current time of day.
local ui_nowline = wibox.widget({
  {
    forced_height = dpi(2),
    forced_width  = DAYCOL_WIDTH,
    bg     = beautiful.red,
    widget = wibox.container.background,
    point  = { x = HOUR_LABEL_WIDTH + nowline_x_offset, y = 0 },
  },
  layout = wibox.layout.manual,

  -- Called whenever agenda tab is opened to reposition the nowline
  reposition = function(self)
    local now_hr  = tonumber(os.date("%H", os.time()))
    local now_min = tonumber(os.date("%M", os.time()))
    local now = now_hr + (now_min/60)
    self.children[1].point.y = calc_y_pos(now)
    self.children[1].point.x = HOUR_LABEL_WIDTH + nowline_x_offset
  end
})

-- █░█ █ ▀    █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▄▄ █▀█ ▀▄▀ █▀▀ █▀ 
-- █▄█ █ ▄    ██▄ ▀▄▀ ██▄ █░▀█ ░█░ █▄█ █▄█ █░█ ██▄ ▄█ 

-- Create a single event box to be inserted into a day column.
-- @param event   A table of event data for a single event (parsed from gcalcli by calcore)
-- @param num_overlaps  How many events that this event overlaps.
local function ui_create_eventbox(event, num_overlaps)
  num_overlaps = num_overlaps or 0

  local title = event[cal.TITLE]
  local stime = event[cal.START_TIME]
  local etime = event[cal.END_TIME]
  local where = event[cal.LOCATION] or ""

  if string.find(where, "zoom") then
    where = "Zoom"
  end

  local eventbox = wibox.widget({
    { -- Title
      id     = "title",
      markup = ui.colorize(title, beautiful.fg_0),
      font   = beautiful.font_med_xs,
      widget = wibox.widget.textbox,
    },
    { -- Times
      markup = ui.colorize(stime .. " - " .. etime, beautiful.fg_1),
      font   = beautiful.font_reg_xs,
      widget = wibox.widget.textbox,
    },
    { -- Location
      markup = ui.colorize(where, beautiful.fg_1),
      font   = beautiful.font_reg_xs,
      widget = wibox.widget.textbox,
    },
    spacing = dpi(2),
    widget  = wibox.layout.fixed.vertical,
  })

  for i = 1, #eventbox.children do
    eventbox.children[i].ellipsize = "end"
    eventbox.children[i].forced_width = EVENTBOX_WIDTH
  end

  local event_bg = OVERLAP_BG[num_overlaps + 1]
  local x = num_overlaps * OVERLAP_X_ADJUST

  local stime_int = timestr_to_int(stime)
  local etime_int = timestr_to_int(etime)

  -- Final assembly of eventbox
  local ebox = wibox.widget({
    {
      {
        -- Content
        eventbox,
        margins = dpi(5),
        widget  = wibox.container.margin,
      },
      -- Accent bar
      left   = dpi(3),
      color  = beautiful.primary_0,
      widget = wibox.container.margin,
    },
    forced_width  = EVENTBOX_WIDTH,
    forced_height = calc_event_height(stime_int, etime_int),
    bg     = event_bg,
    shape  = ui.rrect(),
    widget = wibox.container.background,

    -- Coords of where it will appear in the day column
    point = { x = x, y = calc_y_pos(stime_int) },

    -- Used later for overlap checking
    endtime = etime_int,
  })

  local nav_ebox = keynav.navitem.background({
    widget = ebox,
    bg_off = event_bg,
    bg_on  = beautiful.bg_4,
  })

  return ebox, nav_ebox
end


-- Container for all 7 day columns.
local ui_all_daycolumns = wibox.widget({
  spacing = DAYCOL_SPACING,
  layout  = wibox.layout.fixed.horizontal,
})

--- Create a single day column.
-- @param events Table of event data from gcalcli.
local function ui_create_daycolumn(events)
  local daycol = wibox.widget({
    forced_width  = DAYCOL_WIDTH,
    forced_height = DAYCOL_HEIGHT,
    layout = wibox.layout.manual,
  })

  if not events then return daycol end

  local nav_daycol = keynav.area({
    name     = "daycol",
    circular = true,
  })

  -- Add events to daycolumn
  for i = 1, #events do
    local cur_stime = events[i][cal.START_TIME]
    local cur_etime = events[i][cal.END_TIME]
    cur_stime = timestr_to_int(cur_stime)
    cur_etime = timestr_to_int(cur_etime)

    -- Check for overlapping events.
    -- Overlaps when previous endtime > current start time 
    local num_overlaps = 0
    for j = 1, #daycol.children do
      local prev_etime = daycol.children[j].endtime
      if prev_etime > cur_stime then
        num_overlaps = num_overlaps + 1
      end
    end

    local ebox, nav_ebox = ui_create_eventbox(events[i], num_overlaps)
    daycol:add(ebox)
    nav_daycol:append(nav_ebox)
  end

  return daycol, nav_daycol
end

-- Final widget assembly
local ui_final = wibox.widget({
  {
    ui_gridlines,
    top    = DAYCOL_HEADER_HEIGHT + DAYCOL_GRIDLINE_MARGIN,
    left   = HOUR_LABEL_WIDTH - dpi(5),
    widget = wibox.container.margin,
  },
  {
    {
      ui_timelabels,
      top    = DAYCOL_HEADER_HEIGHT + DAYCOL_GRIDLINE_MARGIN,
      widget = wibox.container.margin,
    },
    ui_all_daycolumns,
    layout = wibox.layout.fixed.horizontal,
  },
  {
    ui_nowline,
    top    = DAYCOL_HEADER_HEIGHT + DAYCOL_GRIDLINE_MARGIN,
    widget = wibox.container.margin,
  },
  layout = wibox.layout.stack,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

-- Draw everything once data is ready
cal:connect_signal("ready::weekview", function()
  -- Reset
  ui_all_daycolumns:reset()
  nav_weekview:reset()

  local this_time = os.time()

  -- Start from Sunday if specified in config
  if not config.agenda.weekview_start_from_today then
    local weekday = tonumber(os.date("%w")) -- a number 0-6
    this_time = this_time - (weekday * SECONDS_IN_DAY)
    nowline_x_offset = (weekday * DAYCOL_WIDTH) + (weekday * DAYCOL_SPACING)
  end

  -- Once all events are ready, create daycolumns
  for _ = 1, DAYS_TO_DISPLAY, 1 do
    local this_year  = os.date("%Y", this_time)
    local this_month = os.date("%m", this_time)
    local this_date  = os.date("%d", this_time)

    -- UI for header
    local day_of_week = tostring(os.date("%a", this_time))
    local dcol_header = wibox.widget({
      { -- Day of week text
        markup = ui.colorize(day_of_week, beautiful.fg_1),
        align  = "center",
        font   = beautiful.font_reg_s,
        widget = wibox.widget.textbox,
      },
      { -- Date text
        markup = ui.colorize(this_date, beautiful.fg_0),
        align  = "center",
        font   = beautiful.font_bold_m,
        widget = wibox.widget.textbox,
      },
      forced_height = DAYCOL_HEADER_HEIGHT + DAYCOL_GRIDLINE_MARGIN,
      forced_width  = DAYCOL_WIDTH,
      layout = wibox.layout.fixed.vertical,
    })

    -- Generate each event column
    local events = cal.events[this_year][this_month][this_date]
    local dcol, nav_dcol = ui_create_daycolumn(events)

    ui_all_daycolumns:add(wibox.widget({
      dcol_header,
      dcol,
      forced_width = DAYCOL_WIDTH,
      layout = wibox.layout.fixed.vertical,
    }))

    if nav_dcol and #nav_dcol.items > 0 then
      nav_weekview:append(nav_dcol)
    end

    this_time = this_time + SECONDS_IN_DAY
  end
end)

-- Redraw the nowline every time weekview is opened
dash:connect_signal("agenda::view_selected", function(_, view)
  if view == "weekview" then
    ui_nowline:reposition()
  end
end)

return function()
  ui_timelabels:init()
  ui_gridlines:init()
  ui_nowline:reposition()
  return ui_final, nav_weekview
end
