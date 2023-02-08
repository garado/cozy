
-- █░█░█ █░█ █▀▀ █▀█ █▀▀ ▀ █▀    ▀█▀ █░█ █▀▀    █▀▄ ▄▀█ █▀▄▀█ █▄░█    █▄▄ █░█ █▀ ▀█ 
-- ▀▄▀▄▀ █▀█ ██▄ █▀▄ ██▄ ░ ▄█    ░█░ █▀█ ██▄    █▄▀ █▀█ █░▀░█ █░▀█    █▄█ █▄█ ▄█ ░▄ 

-- I hate waiting.

-- Field              Function
-- -----------------  -----------------
-- self.timer         - Gears.timer that periodically fetches bus data with curl
-- self.route_info    - A reference to a table containing destination and stop id
--                      This field is set by the route select navitem in bus/select.lua
--                      These tables are defined in cozyconf.
-- self.data          - Table containing bus data fetched from cruzmetro
-- self.count         - For certain routes I can take buses that go on either side of the street.
--                      This is a counter for the number of async calls performed so that I know
--                      when I have data for both stops
-- self.last_updated  - String used by view_track containing the last time that data was fetched

-- On self.data structure
-- -------------------
-- self.data {
--    { routename, minutes_to_arrival, scheduled_arrival }
--    { "18", 50 , _ },
-- }

-- On curl'd data format
-- --------------------------
-- The curl command returns a numerically-indexed table whose fields correspond
-- to a bus route. Each bus route contains another field "Arrivals" where the
-- desired data is stored.

local gobject  = require("gears.object")
local gtable   = require("gears.table")
local awful    = require("awful")
local json     = require("modules.json")
local core     = require("helpers.core")
local gears    = require("gears")
local pushover = require("core.web.pushover")

local bus   = {}
local instance = nil

local UPDATE_INTERVAL = 60 * 2 -- 2 min
local MINUTES   = 1
local ROUTE     = 2
local SCHEDULED = 3

--- Generates the url to curl
-- @param stop The stop id
local function gen_url(stop)
  return 'https://cruzmetro.com/Stop/'..stop..'/Arrivals'
end

-- Set timer to repeat curl command every so often
function bus:start_tracking()
  self.timer = gears.timer{
    timeout   = UPDATE_INTERVAL,
    call_now  = true,
    autostart = true,
    callback  = function()
      self:get_data(self.route_info.id)
      self.last_updated = os.date("%I:%M %p")
    end
  }
end

-- Stop repeat curl command
function bus:stop_tracking()
  self.timer:stop()
  self.data = nil
  self.route_info = nil
end

-- Curl cruzmetro and parse json for all stops given
function bus:get_data(stop)
  self.data = {}
  -- Handle having 2 stop ids (stops on both sides of the street), in
  -- which case the 'stop' argument would be a table of ints instead of an int
  if type(stop) == "table" then
    self.count = #stop
    for i = 1, #stop do
      self:get_data_single_stop(stop[i])
    end
  else
    self.count = 1
    self:get_data_single_stop(stop)
  end
end

function bus:get_data_single_stop(stop)
  local url = gen_url(stop)
  local cmd = "curl '" .. url .. "'"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local json_arr = json.decode(stdout)
    for i = 1, #json_arr do
      local info = json_arr[i]["Arrivals"][1]
      local min_to_arrival = info["Minutes"]
      local route_name     = core.split('-', info["RouteName"])[1]
      local scheduled_time = info["ScheduledTime"]

      -- Metro arrival time, if applicable
      local est_arrival
      if self.route_info["min_to_metro"] then
        local min_to_metro = self.route_info["min_to_metro"][route_name]
        local min = (min_to_metro + min_to_arrival) * 60
        est_arrival = os.date("%H:%M", (os.time() + min))
        print('arr. ' .. est_arrival)
      end

      table.insert(self.data, { min_to_arrival, route_name, scheduled_time, est_arrival })
    end

    -- If all async calls have completed, tell UI to update
    self.count = self.count - 1
    if self.count == 0 then
      -- Sort by nearest arrival first
      table.sort(self.data, function(a, b)
        return a[self.MINUTES_TO_ARRIVAL] < b[self.MINUTES_TO_ARRIVAL]
      end)

      -- Then check if should send Pushover notification
      for i = 1, #self.data do
        local min = self.data[i][MINUTES]
        if min <= 10 then
          local title = "Trip from " .. self.route_info["from"] .. " to " .. self.route_info["to"]
          local msg = self.data[i][ROUTE] .. " coming in " .. min .. " minutes"
          -- pushover:post(title, msg)
          break
        end
      end

      self:emit_signal("data::ready")
    end
  end)
end

function bus:new()
  self:connect_signal("tracking::start", self.start_tracking)
  self:connect_signal("tracking::stop", self.stop_tracking)
  self.last_updated = "-"

  -- Enum for accessing self.data
  self.MINUTES_TO_ARRIVAL = 1
  self.ROUTE_NAME = 2
  self.SCHEDULED_TIME = 3
  self.METRO_ARR = 4
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, bus, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
