
-- █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄ 

-- Mostly based on:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/weather-widget

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local core    = require("helpers.core")

local weather  = { }
local instance = nil
local cache_path = gfs.get_cache_dir() .. "weather"

--------------------------------

--- Maps openWeatherMap icon name to file name w/o extension
local icon_map = {
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

--------------------------------

function weather:new()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, weather, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
