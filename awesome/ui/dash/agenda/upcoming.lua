
-- █░█ █▀█ █▀▀ █▀█ █▀▄▀█ █ █▄░█ █▀▀ 
-- █▄█ █▀▀ █▄▄ █▄█ █░▀░█ █ █░▀█ █▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local gears = require("gears")
local helpers = require("helpers")
local gfs = require("gears.filesystem")

local colorize = require("helpers.ui").colorize_text

local os = os
local string = string
local table = table

local events = {}

-- split tsv into lines (events) + their fields
local function parse_tsv(tsv)
  -- insert each event into a table
  local event_list = {}
  local num_events = 0
  for event in string.gmatch(tsv, "[^\r\n]+") do
    num_events = num_events + 1
    table.insert(event_list, event)
  end

  -- parse tsv
  for i = 1, #event_list do
    -- split on tabs
    local fields = {}
    for field in string.gmatch(event_list[i], "[^\t]+") do
      table.insert(fields, field)
    end

    -- date comes in 2022-08-23 format
    -- change to Tue Aug 23
    local date = fields[1]
    local pattern = "(%d%d%d%d)-(%d%d)-(%d%d)"
    local xyear, xmon, xday = date:match(pattern)
    local ts = os.time({ year = xyear, month = xmon, day = xday })
    local format_date = os.date("%a %b %d", ts)

    local event = {
      ["name"]  = fields[6],
      ["start"] = fields[2],
      ["end_"]  = fields[4],
      ["date"]  = format_date,
      ["desc"]  = fields[8],
      ["place"] = fields[7],
    }
    table.insert(events, event)
  end
end

-- Assemble a single event box
local function create_eventbox(entry)
  local accent = beautiful.random_accent_color()

  local name = textbox({
    text = entry["name"],
    color = accent,
    bold = true,
    size = 14,
    halign = "left",
    valign = "center",
  })

  local date = textbox({
    text = entry["date"],
    size = 12,
    bold = true,
    halign = "left",
    valign = "center",
  })

  local times = textbox({
    text = entry["start"] .. " - " .. entry["end_"],
    size = 12,
    halign = "left",
    valign = "center",
  })

  local place = textbox({
    text = entry["place"],
    size = 12,
    halign = "left",
    valign = "center",
  })

  local details = wibox.widget({
    name,
    {
      date,
      times,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    place,
    spacing = dpi(2),
    forced_width = dpi(400),
    layout = wibox.layout.fixed.vertical,
  })

  local accent_bar = wibox.widget({
    bg = accent,
    forced_width = dpi(5),
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  local eventbox = wibox.widget({
    {
      {
        {
          accent_bar,
          details,
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        top    = dpi(5),
        left   = dpi(10),
        right  = dpi(10),
        bottom = dpi(5),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place,
    },
    forced_height = dpi(90),
    forced_width = dpi(300),
    bg = beautiful.bg_l0,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  return eventbox
end

local event_list = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local function create_all_eventboxes()
  local file = gfs.get_cache_dir() .. "calendar/agenda"
  local cmd = "cat " .. file
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    print(stderr)
    parse_tsv(stdout)
    for i = 1, #events do
      local eventbox = create_eventbox(events[i])
      event_list:add(eventbox)
      if #event_list.children >= 7 then
        break
      end
    end
  end)
end

create_all_eventboxes()

local widget = wibox.widget({
  {
    wibox.widget({
      markup  = colorize("Upcoming", beautiful.fg),
      font    = beautiful.font_name .. "17",
      align   = "center",
      valign  = "center",
      widget  = wibox.widget.textbox,
    }),
    event_list,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  top = dpi(20),
  bottom = dpi(20),
  widget = wibox.container.margin,
})

return widget
