
-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▄▄ █▀█ ▀▄▀ 
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ █▄█ █▄█ █░█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local dash  = require("backend.cozy.dash")
local cal   = require("backend.system.calendar")
local calconf = require("cozyconf").calendar
local strutil = require("utils").string
local keynav = require("modules.keynav")
local math  = math

local eventboxes = wibox.widget({
  layout = wibox.layout.manual,
})

eventboxes.area = keynav.area({
  name = "nav_eventboxes",
  keys = {
    ["m"] = function(self)
      if not self.active_element then return end
      local x = self.active_element.widget.point.x
      local y = self.active_element.widget.point.y
      dash:emit_signal("calpopup::toggle", x, y, self.active_element.event)
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

--- @function find_overlapping_events
-- @brief Find the number of events that this overlaps.
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
  local hourline_spacing = height / hour_range

  -- Determine how wide each day is
  local day_range = calconf.end_day - calconf.start_day + 1
  local dayline_spacing = width / day_range

  local duration = strutil.time_to_int(event.e_time) -
                   strutil.time_to_int(event.s_time)

  -- Determine y-pos of event box (hour)
  local y = (strutil.time_to_int(event.s_time) * hourline_spacing) -
            (cal.start_hour * hourline_spacing)
  y = y + (EBOX_MARGIN / 2)

  -- Determine x-pos of event box (day)
  local x = (strutil.date_to_weekday_int(event.s_date) - calconf.start_day) * dayline_spacing
  x = x + (EBOX_MARGIN / 2)

  -- Since we can scroll up/down through hours on the calendar, some
  -- eventboxes need to be truncated.
  local truncate = y < 0
  local truncate_duration = math.abs(y)

  if truncate then y = 0 end

  -- If this event has fully elapsed, it should be grayed out.
  local bg, fg
  local now = os.date("%H:%M")
  local now_weekday = os.date("%w")
  local elapsed = false

  elapsed = (cal.weekview_cur_offset < 0) or
            (cal.weekview_cur_offset == 0 and
            ((strutil.date_to_weekday_int(event.e_date) < now_weekday) or
            (strutil.date_to_weekday_int(event.e_date) == now_weekday and event.e_time < now)))

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

  fg = fg or beautiful.fg

  -- Different sized event boxes have different layouts.
  -- (Trying to make a "responsive" event box.)
  local text_top_margin = dpi(6)
  local text_layout = wibox.layout.fixed.vertical
  local time_prefix = ""
  local text_title_height

  if duration <= 0.5 then
    duration = 0.5
    text_top_margin = dpi(2)
    text_layout = wibox.layout.fixed.horizontal
    time_prefix = ', '
  elseif duration <= 0.75 then
    text_top_margin = dpi(3)
    text_layout = wibox.layout.fixed.horizontal
  elseif duration <= 1 then
    text_title_height = beautiful.font_sizes.s * 1.5
  end

  local text = wibox.widget({
    ui.textbox({
      text = event.title,
      font = beautiful.font_med_s,
      height = text_title_height,
      color  = fg,
    }),
    ui.textbox({
      text  = time_prefix .. event.s_time .. ' - ' .. event.e_time,
      color = fg,
    }),
    layout = text_layout,
  })

  local h = (duration * hourline_spacing) - EBOX_MARGIN
  if truncate then h = h - truncate_duration end

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
    bg    = bg,
    shape = ui.rrect(5),
    forced_height = h,
    forced_width  = w,
    widget = wibox.container.background,
    point  = { x = x, y = y },
  })

  -- Custom navitem
  ebox.nav = keynav.navitem.base({ widget = ebox })
  ebox.nav.event = event

  function ebox.nav:select_on()
    self.selected = true
    self.widget.widget.color = beautiful.primary[200]
  end

  function ebox.nav:select_off()
    self.selected = false
    self.widget.widget.color = self.widget.bg
  end

  function ebox.nav:modify()
    print('Modifying ebox '..self.event.title)
  end

  return ebox
end

function eventboxes:add_event(e)
  local ebox = gen_eventbox(e, self._height, self._width)
  self:add(ebox)
  self.area:append(ebox.nav)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

local function weekview_update()
  local ts = cal:get_weekview_start_ts() + cal.weekview_cur_offset
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
