
-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▀
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local gfs = require("gears.filesystem")

local os = os
local string = string
local table = table

local function widget()
  local placeholder = wibox.widget({
    markup = helpers.ui.colorize_text("No events found", beautiful.fg),
    align = "center",
    valign = "center",
    font = beautiful.font .. "12",
    widget = wibox.widget.textbox,
  })

  -- actual events get appended here later
  local events = wibox.widget({
    placeholder,
    spacing = dpi(3),
    layout = wibox.layout.flex.vertical,
  })

  local header = wibox.widget({
    helpers.ui.create_dash_widget_header("Events"),
    margins = dpi(5),
    widget = wibox.container.margin,
  })

  local widget = wibox.widget({
    {
      header,
      {
        events,
        widget = wibox.container.place,
      },
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.margin,
    margins = dpi(5),
  })

  -- inserts entry into events wibox
  local function create_calendar_entry(date, time, desc)
    local datetime_text = date .. " " .. time
    local datetime = wibox.widget({
      markup = helpers.ui.colorize_text(datetime_text, beautiful.fg),
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local desc_ = wibox.widget({
      markup = helpers.ui.colorize_text("   " .. desc, beautiful.fg),
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local event = wibox.widget({
      datetime,
      desc_,
      layout = wibox.layout.fixed.horizontal,
    })

    events:add(event)
  end

  -- split tsv into lines (events) + their fields
  local function parse_tsv(tsv)
    -- insert each event into a table
    event_list = {}
    num_events = 0
    for event in string.gmatch(tsv, "[^\r\n]+") do
      num_events = num_events + 1
      table.insert(event_list, event)
    end
    
    -- remove placeholder if events were found
    if num_events > 0 then
      events:remove(1)
    else
      return
    end

    -- parse tsv
    for i = 1, #event_list do
      -- split on tabs
      fields = { }
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

      local time = fields[2]
      local desc = fields[5]
      create_calendar_entry(format_date, time, desc)
    end 
  end

  local function update_calendar()
    local file = gfs.get_cache_dir() .. "calendar/agenda"
    local cmd = "cat " .. file
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      if stdout ~= nil and stdout ~= '' then
        parse_tsv(stdout)
      else
        local gcalcli_cmd = "gcalcli agenda today '2 weeks' --tsv"
        awful.spawn.easy_async_with_shell(gcalcli_cmd, function(stdout)
          parse_tsv(stdout)
          awful.spawn.with_shell("echo -e '" .. stdout .. "' > " .. file)
        end)
      end
    end)
  end
  
  awesome.connect_signal("widget::calendar_update", function()
    events:reset()
    update_calendar()
  end)
  
  update_calendar()

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(220), dpi(200), beautiful.dash_widget_bg)

