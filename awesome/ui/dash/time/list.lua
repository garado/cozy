
-- █░░ █ █▀ ▀█▀ 
-- █▄▄ █ ▄█ ░█░ 

-- Displays a list of the most recent Timewarrior entries.
-- Shows date, start and end times, duration, tag, and annotation.

local beautiful   = require("beautiful")
local wibox = require("wibox")
local dpi   = beautiful.xresources.apply_dpi
local time  = require("core.system.time")

local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local datestr_to_ts = require("helpers.dash").datestr_to_ts

-------------------

local MAX_SESSIONS_SHOWN = 22

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

--- Parse Timewarrior data json to create a single session wibox
-- to add to the session list.
-- @param   session_data  Table containing Timewarrior json data
-- @return  A wibox containing Timewarrior session entry.
local function ui_create_entry(session_data)
  if not session_data then return end

  local start_ts = datestr_to_ts(session_data["start"])

  local id = wibox.widget({
    markup = colorize("@" .. session_data["id"], beautiful.fg),
    forced_width = dpi(40),
    widget = wibox.widget.textbox,
  })

  local tag_text = session_data["tags"][1]
  local tag_color = time:tag_color(tag_text)
  local tags = wibox.widget({
    markup = colorize(tag_text, tag_color),
    forced_width = dpi(100),
    widget = wibox.widget.textbox,
  })

  local anno = wibox.widget({
    markup = colorize(session_data["annotation"], beautiful.fg),
    forced_width = dpi(350),
    ellipsize = "end",
    widget = wibox.widget.textbox,
  })

  local date_text = os.date("%a %m/%d", start_ts)
  local date = wibox.widget({
    markup = colorize(date_text, beautiful.fg),
    forced_width = dpi(120),
    widget = wibox.widget.textbox,
  })

  local duration_text = (session_data["duration"] and session_data["duration"] .. "h") or "-"
  local duration = wibox.widget ({
    markup = colorize(duration_text, beautiful.fg),
    forced_width = dpi(100),
    align  = "right",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    {
      id,
      tags,
      anno,
      date,
      duration,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })
end

--- Loop and create all Timewarrior session entries.
-- Add each entry to the list.
-- @param   none
-- @return  Wibox containing all Timewarrior session entries.
local function ui_create_all_entries()
  local cont = wibox.widget({
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })

  for i = 0, MAX_SESSIONS_SHOWN do
    -- The most recent should be the last entry
    local entry = ui_create_entry(time:idx(MAX_SESSIONS_SHOWN - i))
    if entry then
      cont:add(entry)
    end
  end

  return wibox.widget({
    cont,
    widget = wibox.container.place,
  })
end

----------------------------------------------------

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local header = wibox.widget({
  {
    {
      markup = colorize("Recent Sessions", beautiful.fg),
      valign = "center",
      halign = "center",
      font   = beautiful.alt_large_font,
      widget = wibox.widget.textbox,
    },
    widget = wibox.container.place,
  },
  bottom = dpi(5),
  widget = wibox.container.margin,
})

local list_cont = wibox.widget({
  header,
  layout = wibox.layout.fixed.vertical,
  -----
  _reset = function(self)
    self:reset()
    self:add(header)
  end
})

time:connect_signal("ready::month_data", function(_, month)
  list_cont:_reset()
  list_cont:add(ui_create_all_entries())
end)

local widget = wibox.widget({
  list_cont,
  margins = dpi(5),
  widget = wibox.container.margin,
})

return box(widget, dpi(1000), dpi(800), beautiful.dash_widget_bg)
