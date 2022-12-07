
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- A dashboard tab for viewing and modifying Timewarrior stats.

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local awful = require("awful")
local area = require("modules.keynav.area")
local json = require("modules.json")

local datestr_to_ts = require("helpers.dash").datestr_to_ts
local round = require("helpers.dash").round

-- █▀▄ ▄▀█ ▀█▀ ▄▀█    █░█░█ █▀█ ▄▀█ █▄░█ █▀▀ █░░ █ █▄░█ █▀▀ 
-- █▄▀ █▀█ ░█░ █▀█    ▀▄▀▄▀ █▀▄ █▀█ █░▀█ █▄█ █▄▄ █ █░▀█ █▄█ 

-- Call timew export to fetch data for this month, then convert
-- the json to a table. This table is then passed to all widgets
-- in this tab.

local data = gobject{}
data.entry        = {}
data.num_entries  = 0
data.days         = {}

local monthname = string.lower(tostring(os.date("%B")))
local cmd = "timew export " .. monthname

awful.spawn.easy_async_with_shell(cmd, function(stdout)
  local empty_json = "[\n]\n"
  if stdout ~= empty_json and stdout ~= "" then
    data.entry = json.decode(stdout)
    data.num_entries = #data.entry
  end

  for i in ipairs(data.entry) do
    local start_ts = datestr_to_ts(data.entry[i]["start"])
    local end_ts   = data.entry[i]["end"] and datestr_to_ts(data.entry[i]["end"])
    local dur_ts

    if end_ts then
      dur_ts = end_ts - start_ts
      local dur_hours = (dur_ts / 60) / 60
      dur_hours = round(dur_hours, 2)
      data.entry[i]["duration"] = dur_hours
    end
  end

  -- This signal is caught by all widgets and tells them that they
  -- can start processing the data since it's ready.
  data:emit_signal("timew::json_processed")
end)

--- The table of entries is indexed backwards (ie entries[1] is the last entry)
-- so this is a helper function to index properly.
-- @param   index The desired session index.
function data.idx(index)
  local idx = data.num_entries - (index - 1)
  return data.entry[idx]
end

-------------------------------------------------------------

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- Import widgets
-- local cal, nav_cal = require("ui.dash.time.calendar")()
local cal   = require("ui.dash.time.calendar")(data)
local stats = require("ui.dash.time.stats")(data)
local list  = require("ui.dash.time.list")(data)

local time_dash = wibox.widget({
  {
    {
      cal,
      stats,
      spacing = dpi(15),
      layout = wibox.layout.fixed.vertical,
    },
    list,
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

return function()
  return time_dash
end
