
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Timewarrior.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local json    = require("modules.json")
local core    = require("helpers.core")
local beautiful = require("beautiful")

local datestr_to_ts = require("helpers.dash").datestr_to_ts
local round = require("helpers.dash").round

local time = { }
local instance = nil

time.month_names = {
  ["january"]   = 1,
  ["february"]  = 2,
  ["march"]     = 3,
  ["april"]     = 4,
  ["may"]       = 5,
  ["june"]      = 6,
  ["july"]      = 7,
  ["august"]    = 8,
  ["september"] = 9,
  ["october"]   = 10,
  ["november"]  = 11,
  ["december"]  = 12,
}

time.accent_index = 1

time.tag_colors = {}

---------------------------------------------------------------------

--- Return the total time spent working on a particular project for a particular tag.
function time:get_time_per_project(tag, project)
  local _tag = tag .. ":" .. project
  local cmd = "timew sum :all " .. _tag .. " | tail -n 2 | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if not self._private.tags then self._private.tags = {} end
    if not self._private.tags[tag].projects then
      self._private.tags[tag].projects = {}
    end

    -- If first char is a space, then there was (probably?) a valid
    -- Timewarrior output
    local first_char = string.sub(stdout, 1, 1)
    local proj_time
    if first_char ~= " " and first_char ~= "\t" then
      proj_time = ""
    else
      proj_time = string.gsub(stdout, "[^0-9:]", "")
    end

    self._private.tags[tag]["projects"][project] = proj_time

    self:emit_signal("update::project_stats")
  end)
end

-- Call timew export to fetch data for this month and store data in table.
-- @param month   Full name of month as lowercase string
function time:parse_month_data(month)
  month = month or string.lower(tostring(os.date("%B")))

  local cmd = "timew export " .. month
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local empty_json = "[\n]\n"
    if stdout ~= empty_json and stdout ~= "" then
      self.entry = json.decode(stdout)
      self.num_entries = #self.entry
    end

    self.tags = {}
    for i in ipairs(self.entry) do
      local tag = self.entry[i]["tags"][1]
      if not self.tags[tag] then self.tags[tag] = {} end

      local start_ts = datestr_to_ts(self.entry[i]["start"])
      local end_ts   = self.entry[i]["end"] and datestr_to_ts(self.entry[i]["end"])
      local dur_ts

      if end_ts then
        dur_ts = end_ts - start_ts
        local dur_hours = (dur_ts / 60) / 60
        dur_hours = round(dur_hours, 2)
        self.entry[i]["duration"] = dur_hours
      end
    end

    -- This signal is caught by all widgets and tells them that they
    -- can start processing the data since it's ready.
    self:emit_signal("ready::month_data", month)
  end)
end

--- Parse hours by day and store in time.days{}
function time:parse_hours_by_day()
  -- Find the first date
  local first_ts  = datestr_to_ts(self.entry[1]["start"])
  local last_date = tonumber(os.date("%d", first_ts)) or 0
  local hours_this_date = 0

  self.days = {}
  for i in ipairs(self.entry) do
    local ts = datestr_to_ts(self.entry[i]["start"])
    local this_date = tonumber(os.date("%d", ts)) or 0

    -- The date is different, which means we finished processing all 
    -- the entries from the last day, so we can update the heatmap for
    -- the last day
    if this_date ~= last_date or i == self.num_entries then
      -- Provide info for other modules that keep track of hours by date 
      self.days[last_date] = hours_this_date

      last_date = this_date
      hours_this_date = 0
    end

    -- Update hours this date
    hours_this_date = hours_this_date + (self.entry[i]["duration"] or 0)
  end

  self:emit_signal("ready::hours_by_day")
  self:emit_signal("ready::tags")
end

--- The table of entries is indexed backwards (ie entries[1] is the last entry)
-- so this is a helper function to index properly.
-- @param   index The desired session index.
function time:idx(index)
  local idx = self.num_entries - (index - 1)
  return self.entry[idx]
end

--- Determine if Timewarrior is currently tracking time.
function time:determine_if_active()
  local cmd = "timew"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if string.match(stdout, "There is no active time tracking") then
      self.tracking_active = false
      self:emit_signal("tracking_inactive")
    else
      self.tracking_active = true
      self:emit_signal("tracking_active")
    end
  end)
end

function time:tag_color(tag)
  if not self.tag_colors[tag] then
    self.tag_colors[tag] = beautiful.accents[#self.tag_colors + 1]
  end

  return self.tag_colors[tag]
end

function time:set_tracking_inactive()
  self.tracking_active = false
  self:emit_signal("tracking_inactive")
end

function time:set_tracking_active()
  self.tracking_active = true
  self:emit_signal("tracking_active")
end

---------------------------------------------------------------------

function time:new()
  self:determine_if_active()
  self:parse_month_data()

  self:connect_signal("ready::month_data", function()
    self:parse_hours_by_day()
  end)

  -- TODO: remove these signals and replace with respective function call
  self:connect_signal("set_tracking_inactive", function()
    self.tracking_active = false
    self:emit_signal("tracking_inactive")
  end)

  self:connect_signal("set_tracking_active", function()
    self.tracking_active = true
    self:emit_signal("tracking_active")
  end)
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, time, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
