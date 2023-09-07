-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▄▄ █▀█ ▀▄▀
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ █▄█ █▄█ █░█

local beautiful      = require("beautiful")
local ui             = require("utils.ui")
local dpi            = ui.dpi
local wibox          = require("wibox")
local dash           = require("backend.cozy.dash")
local cal            = require("backend.system.calendar")
local strutil        = require("utils").string
local keynav         = require("modules.keynav")
local conf           = require("cozyconf")
local math           = math

local eventboxes = wibox.widget({
  layout = wibox.layout.manual,
})

eventboxes.area = keynav.area({
  name = "nav_eventboxes",
  keys = {
    ["m"] = function(self)
      if not self.active_element then return end
      -- local x = self.active_element.point.x
      -- local y = self.active_element.point.y
      -- dash:emit_signal("calpopup::toggle", x, y, self.active_element.event)
      cal.modify_mode = true
      cal.active_element = self.active_element
      cal:emit_signal("add::setstate::toggle")
    end,
    ["d"] = function(self)
      if not self.active_element then return end
      cal:delete(self.active_element.event)
    end
  }
})

local SECONDS_IN_DAY = 24 * 60 * 60
local EBOX_MARGIN    = dpi(4)
local OVERLAP_OFFSET = dpi(7)
local ELAPSED_BG     = beautiful.neutral[600]
local ELAPSED_FG     = beautiful.neutral[300]

local colors = {
  beautiful.primary[900],
  beautiful.primary[700],
  beautiful.primary[500],
  beautiful.primary[300],
  beautiful.primary[100],
}

awesome.connect_signal("theme::reload", function()
  ELAPSED_BG     = beautiful.neutral[600]
  ELAPSED_FG     = beautiful.neutral[300]

  colors = {
    beautiful.primary[900],
    beautiful.primary[700],
    beautiful.primary[500],
    beautiful.primary[300],
    beautiful.primary[100],
  }
end)

--- @function find_overlapping_events
-- @brief Find the number of other events that an overlaps.
-- @param x, y The starting coordinates for an event.
local function find_overlapping_events(x, y)
  local num_overlaps = 0
  for i = 1, #eventboxes.children do
    local _x = eventboxes.children[i].point.x
    local _y = eventboxes.children[i].point.y
    local _h = eventboxes.children[i].forced_height

    if _x == x and y >= _y and y <= (_y + _h) then
      num_overlaps = num_overlaps + 1
    end
  end

  return num_overlaps
end

--- @function gen_eventbox
-- @param event An event table
local function gen_eventbox(event, height, width)
  -- Determine how tall each hour is
  local hour_range = cal.end_hour - cal.start_hour + 1
  local hour_height = height / hour_range

  -- Determine how wide each day is
  local num_days = 7
  local dayline_spacing = width / num_days

  local duration = strutil.time_to_float(event.e_time) -
      strutil.time_to_float(event.s_time)

  -- Determine y-pos of event box (hour)
  local y = (strutil.time_to_float(event.s_time) * hour_height) -
      (cal.start_hour * hour_height)
  y = y + (EBOX_MARGIN / 2)

  -- Determine x-pos of event box (day)
  local x = (strutil.dt_convert(event.s_date, nil, "%w")) * dayline_spacing
  x = x + (EBOX_MARGIN / 2)

  -- Since we can scroll up/down through hours on the calendar, some
  -- eventboxes need to be truncated.
  local MAX_Y = (cal.end_hour - cal.start_hour + 1) * hour_height

  -- Height of eventbox
  local h = (duration * hour_height) - EBOX_MARGIN

  if y + h < 0 or y >= MAX_Y then
    return
  elseif y < 0 then
    h = h - math.abs(y)
    y = 0
  end

  if (y + h) >= MAX_Y then
    h = h - ((y + h) - MAX_Y)
  end

  -- If this event has fully elapsed, it should be greyed out.
  local bg, fg
  local now = os.date("%H:%M")
  local now_weekday = os.date("%w")
  local elapsed = false

  elapsed = (cal.weekview_cur_offset < 0) or
      (cal.weekview_cur_offset == 0 and
      ((strutil.dt_convert(event.e_date, nil, "%w") < now_weekday) or
      (strutil.dt_convert(event.e_date, nil, "%w") == now_weekday and event.e_time < now)))

  if elapsed then
    bg = ELAPSED_BG
    fg = ELAPSED_FG
  end

  -- If this event overlaps others, adjust the properties of this
  -- event box accordingly.
  local w = dayline_spacing - EBOX_MARGIN
  local num_overlaps = find_overlapping_events(x, y)
  x = x + (num_overlaps * OVERLAP_OFFSET)
  w = w - (num_overlaps * OVERLAP_OFFSET)
  bg = bg or colors[num_overlaps + 1]

  fg = fg or beautiful.neutral[100]

  -- Different sized event boxes have different layouts.
  -- Below we're just trying to make a "responsive" event box.
  -- TODO: Still needs work.
  local text_top_margin = dpi(6)
  local text_layout = wibox.layout.fixed.vertical
  local time_prefix = ""
  local text_title_height

  if h <= 0.5 * hour_height then
    h = 0.5 * hour_height
    text_top_margin = dpi(2)
    text_layout = wibox.layout.fixed.horizontal
    time_prefix = ', '
  elseif h <= 0.75 * hour_height then
    text_top_margin = dpi(3)
    text_layout = wibox.layout.fixed.horizontal
  elseif h <= hour_height then
    text_title_height = conf.font.sizes.s * 1.5
  end

  local text = wibox.widget({
    ui.textbox({
      text   = event.title,
      font   = beautiful.font_med_s,
      height = text_title_height,
      color  = fg,
    }),
    ui.textbox({
      text  = time_prefix .. event.s_time .. ' - ' .. event.e_time,
      color = fg,
    }),
    layout = text_layout,
  })

  -- Final assembly + keynav stuff
  local ebox = wibox.widget({
    {
      {
        text,
        top    = text_top_margin,
        left   = dpi(8),
        right  = dpi(8),
        widget = wibox.container.margin,
      },
      margins = dpi(2),
      color   = beautiful.bg,
      widget  = wibox.container.margin,
    },
    bg            = bg,
    shape         = ui.rrect(5),
    forced_height = h,
    forced_width  = w,
    widget        = wibox.container.background,
    point         = { x = x, y = y },
  })

  ebox.event = event

  ebox:connect_signal("mouse::enter", function(self)
    self.widget.color = beautiful.primary[200]
  end)

  ebox:connect_signal("mouse::leave", function(self)
    self.widget.color = self.widget.bg
    dash:emit_signal("calpopup::hide")
  end)

  ebox:connect_signal("button::press", function()
    dash:emit_signal("calpopup::toggle", x, y, event)
  end)

  return ebox
end

function eventboxes:add_event(e)
  local ebox = gen_eventbox(e, self._height, self._width)
  if ebox then
    self:add(ebox)
    self.area:append(ebox)
  end
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

local function weekview_update()
  local ts        = cal:get_weekview_start_ts() + cal.weekview_cur_offset
  local start_day = os.date("%Y-%m-%d", ts)
  local end_day   = os.date("%Y-%m-%d", ts + (7 * SECONDS_IN_DAY))
  cal:fetch_range("weekview", start_day, end_day)
end

dash:connect_signal("weekview::size_calculated", function(_, height, width)
  eventboxes._height = height
  eventboxes._width = width
  weekview_update()
end)

-- TODO: Could probably consolidate these signals somehow
cal:connect_signal("hours::adjust", weekview_update)
cal:connect_signal("cache::ready", weekview_update)
cal:connect_signal("weekview::change_week", weekview_update)
dash:connect_signal("date::changed", weekview_update)

cal:connect_signal("ready::range::weekview", function(_, events)
  eventboxes.area:clear()
  eventboxes.children = {}
  for i = 1, #events do
    local e = events[i]
    eventboxes:add_event({
      title  = e[cal.TITLE],
      s_time = e[cal.START_TIME],
      e_time = e[cal.END_TIME],
      s_date = e[cal.START_DATE],
      e_date = e[cal.END_DATE],
      loc    = e[cal.LOCATION],
    })
  end
end)

return eventboxes
