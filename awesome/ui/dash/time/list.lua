
-- █░░ █ █▀ ▀█▀ 
-- █▄▄ █ ▄█ ░█░ 

-- Displays a list of the most recent Timewarrior entries.
-- Shows date, start and end times, duration, tag, and annotation.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local area = require("modules.keynav.area")
local gears = require("gears")

local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local datestr_to_ts = require("helpers.dash").datestr_to_ts

-------------------

-- The number of sessions to show in the list.
local max_sessions_shown = 22

return function(data)

  -- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
  -- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

  --- Parse Timewarrior data json to create a single session wibox
  -- to add to the session list.
  -- @param   day_data  Table containing Timewarrior json data
  -- @return  A wibox containing Timewarrior session entry.
  local function ui_create_entry(day_data)
    if not day_data then return end

    local start_ts = datestr_to_ts(day_data["start"])

    local id = wibox.widget({
      markup = colorize("@" .. day_data["id"], beautiful.fg),
      forced_width = dpi(40),
      widget = wibox.widget.textbox,
    })

    -- Show 1st tag only
    local tag_text = day_data["tags"][1]
    local tags = wibox.widget({
      markup = colorize(tag_text, beautiful.fg),
      forced_width = dpi(100),
      widget = wibox.widget.textbox,
    })

    local anno = wibox.widget({
      markup = colorize(day_data["annotation"], beautiful.fg),
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

    local duration_text = (day_data["duration"] and day_data["duration"] .. "h") or "-"
    local duration = wibox.widget ({
      markup = colorize(duration_text, beautiful.fg),
      forced_width = dpi(100),
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

    for i = 0, max_sessions_shown do
      -- The most recent should be the last entry
      local entry = ui_create_entry(data.idx(max_sessions_shown - i))
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

  local list_cont = wibox.widget({
    layout = wibox.layout.fixed.vertical,
  })

  -- Since fetching json data is async, we need to wait for that
  -- to finish before assembling UI
  data:connect_signal("timew::json_processed", function(_)
    list_cont:add(ui_create_all_entries())
  end)

  local widget = wibox.widget({
    list_cont,
    margins = dpi(5),
    widget = wibox.container.margin,
  })

  return box(widget, dpi(1000), dpi(800), beautiful.dash_widget_bg)
end

