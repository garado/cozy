
-- █▀█ █▀█ █▀▀ █▄░█ █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█
-- █▄█ █▀▀ ██▄ █░▀█ ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄

-- Fetch current and forecasted weather.

local awful   = require("awful")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local json    = require("modules.json")
local conf    = require("cozyconf")

local key  = conf.weather.key
local lat  = conf.weather.lat
local lon  = conf.weather.lon
local unit = conf.weather.unit

local openweather = {}
local instance = nil

if not key then return false end

---------------------------------------------------------------------

function openweather:fetch_current()
  local cmd = "curl -f \"https://api.openweathermap.org/data/2.5/weather?units="..unit.."&lat="..lat..
              "&lon="..lon.."&appid="..key.."\""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == "" then
      self:emit_signal("failure::current")
    else
      self:emit_signal("ready::current", json.decode(stdout))
    end
  end)
end

--- @method fetch_forecast
-- @brief Fetch weather forecast data from cachefile, populating it if necessary.
-- https://openweathermap.org/forecast5
function openweather:fetch_forecast()
  local cmd = "curl -f \"https://api.openweathermap.org/data/2.5/forecast?units="..unit.."&lat="..lat..
              "&lon="..lon.."&appid="..key.."&cnt=5".."\""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == "" then
      self:emit_signal("failure::forecast")
    else
      self:emit_signal("ready::forecast", json.decode(stdout))
    end
  end)
end

---------------------------------------------------------------------

function openweather:new()
  -- all of these are nerdfonts nf-md-weather_*
  self.icon_map = {
    ["01d"] = "󰖙", -- "clear-sky",
    ["02d"] = "󰖕", -- "few-clouds",
    ["03d"] = "󰖕", -- "scattered-clouds",
    ["04d"] = "󰖐", -- "broken-clouds",
    ["09d"] = "󰖗", -- "shower-rain",
    ["10d"] = "󰖖", -- "rain",
    ["11d"] = "󰙾", -- "thunderstorm",
    ["13d"] = "󰼶", -- "snow",
    ["50d"] = "󰖑", -- "mist",
    ["01n"] = "󰖔", -- "clear-sky-night",
    ["02n"] = "󰼱", -- "few-clouds-night",
    ["03n"] = "󰼱", -- "scattered-clouds-night",
    ["04n"] = "󰼱", -- "broken-clouds-night",
    ["09n"] = "󰖗", -- "shower-rain-night",
    ["10n"] = "󰖖", -- "rain-night",
    ["11n"] = "󰙾", -- "thunderstorm-night",
    ["13n"] = "󰼶", -- "snow-night",
    ["50n"] = "󰖑", -- "mist-night"
  }
end

local function new()
  local ret = gobject {}
  gtable.crush(ret, openweather, true)
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
