-- █▀█ █▀█ █▀▀ █▄░█ █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█
-- █▄█ █▀▀ ██▄ █░▀█ ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄

-- Forecast is cached and updated every 3 hours with anacron.

local gfs             = require("gears.filesystem")
local awful           = require("awful")
local gobject         = require("gears.object")
local gtable          = require("gears.table")
local json            = require("modules.json")
local conf            = require("cozyconf")

local key             = conf.weather.key
local lat             = conf.weather.lat
local lon             = conf.weather.lon
local unit            = conf.weather.unit
local tz              = conf.timezone

local openweather     = {}
local instance        = nil

local SCRIPT_CURRENT  = gfs.get_configuration_dir() .. "utils/scripts/fetch-weather-current"
local SCRIPT_FORECAST = gfs.get_configuration_dir() .. "utils/scripts/fetch-weather-forecast"

if not key then return false end

---------------------------------------------------------------------

--- @method fetch_current
-- @brief Fetch current weather data from cachefile, populating it if necessary.
-- https://openweathermap.org/current
function openweather:fetch_current()
  local CACHEFILE = gfs.get_cache_dir() .. "weather-current"
  if not gfs.file_readable(CACHEFILE) then
    local cmd = SCRIPT_CURRENT .. ' ' .. unit .. ' ' .. lat .. ' ' .. lon .. ' ' .. key
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      self:emit_signal("ready::current", json.decode(stdout))
    end)
  else
    local cmd = "cat " .. CACHEFILE
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      self:emit_signal("ready::current", json.decode(stdout))
    end)
  end
end

--- @method fetch_forecast
-- @brief Fetch weather forecast data from cachefile, populating it if necessary.
-- https://openweathermap.org/forecast5
function openweather:fetch_forecast()
  local CACHEFILE = gfs.get_cache_dir() .. "weather-forecast"
  if not gfs.file_readable(CACHEFILE) then
    local cmd = SCRIPT_FORECAST .. ' ' .. unit .. ' ' .. lat .. ' ' .. lon .. ' ' .. key
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      self:emit_signal("ready::forecast", json.decode(stdout))
    end)
  else
    local cmd = "cat " .. CACHEFILE
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      self:emit_signal("ready::forecast", json.decode(stdout))
    end)
  end
end

---------------------------------------------------------------------

function openweather:new()
  self.icon_map = {
    ["01d"] = "clear-sky",
    ["02d"] = "few-clouds",
    ["03d"] = "scattered-clouds",
    ["04d"] = "broken-clouds",
    ["09d"] = "shower-rain",
    ["10d"] = "rain",
    ["11d"] = "thunderstorm",
    ["13d"] = "snow",
    ["50d"] = "mist",
    ["01n"] = "clear-sky-night",
    ["02n"] = "few-clouds-night",
    ["03n"] = "scattered-clouds-night",
    ["04n"] = "broken-clouds-night",
    ["09n"] = "shower-rain-night",
    ["10n"] = "rain-night",
    ["11n"] = "thunderstorm-night",
    ["13n"] = "snow-night",
    ["50n"] = "mist-night"
  }
end

local function new()
  local ret = gobject {}
  gtable.crush(ret, openweather, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
