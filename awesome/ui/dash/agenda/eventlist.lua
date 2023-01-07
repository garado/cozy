
-- █░█ █▀█ █▀▀ █▀█ █▀▄▀█ █ █▄░█ █▀▀ 
-- █▄█ █▀▀ █▄▄ █▄█ █░▀░█ █ █░▀█ █▄█ 

-- View upcoming events.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local cal = require("core.system.cal")
local area    = require("modules.keynav.area")
local navtext = require("modules.keynav.navitem").Textbox
local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text

local MAX_EVENTS_SHOWN = 20

-- Keyboard navigation
local nav_events = area:new({
  name = "events",
  circular = true,
  keys = require("ui.dash.agenda.commands")
})

-- Assemble a single event box and its corresponding keynav items
local function create_event(startdate, starttime, endtime, title, place)
  local name = wibox.widget({
    markup  = colorize(title, beautiful.fg),
    align   = "left",
    valign  = "center",
    ellipsize = "right",
    forced_width = 210,
    widget  = wibox.widget.textbox,
  })

  local date = wibox.widget({
    markup = colorize(cal:format_date(startdate), beautiful.fg),
    align = "left",
    valign = "center",
    forced_width = 150,
    widget = wibox.widget.textbox,
  })

  local time
  if starttime == "00:00" and starttime == endtime then
    time = "All day"
  else
    time = starttime .. " - " .. endtime
  end
  local times = wibox.widget({
    markup = colorize(time, beautiful.fg),
    align = "left",
    valign = "center",
    forced_width  = 150,
    widget = wibox.widget.textbox,
  })

  local _place = wibox.widget({
    markup = colorize(place, beautiful.fg),
    align = "left",
    valign = "center",
    forced_width  = 200,
    widget = wibox.widget.textbox,
  })

  local details = wibox.widget({
    name,
    date,
    times,
    _place,
    spacing = dpi(8),
    layout  = wibox.layout.fixed.horizontal,
  })

  local event_wibox = wibox.widget({
    details,
    widget = wibox.container.place
  })

  local navevent = navtext:new(name)
  return event_wibox, navevent
end

local event_list = wibox.widget({
  wibox.widget({ -- placeholder
    markup = colorize("No events found.", beautiful.fg),
    align  = "center",
    valign = "center",
    font   = beautiful.base_small_font,
    widget = wibox.widget.textbox,
  }),
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

cal:connect_signal("ready::upcoming", function()
  local upcoming = cal:get_upcoming_events()
  event_list:reset()
  nav_events:remove_all_items()
  nav_events:reset()

  for i = 1, #upcoming do
    if i > MAX_EVENTS_SHOWN then break end
    local date = cal:get_start_date(upcoming[i])
    local stime = cal:get_start_time(upcoming[i])
    local etime = cal:get_end_time(upcoming[i])
    local title = cal:get_title(upcoming[i])
    local loc = cal:get_location(upcoming[i])
    local entry, navevent= create_event(date, stime, etime, title, loc)

    navevent.title = title
    navevent.date  = date
    event_list:add(entry)
    nav_events:append(navevent)
  end
end)

cal:connect_signal("input::request_get_info", function(_, type)
  local cur_navevent = nav_events:get_curr_item()
  cal.cur_title = cur_navevent.title
  cal.cur_date  = cur_navevent.date
  cal:emit_signal("input::request", type)
end)

local widget = wibox.widget({
  wibox.widget({
    markup  = colorize("Upcoming", beautiful.fg),
    font    = beautiful.alt_large_font,
    align   = "center",
    valign  = "center",
    widget  = wibox.widget.textbox,
  }),
  event_list,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

return function()
  return box(widget, dpi(1000), dpi(700), beautiful.dash_widget_bg), nav_events
end
