-------------------------------------------------
-- Weather Widget based on the OpenWeatherMap
-- https://openweathermap.org/
--
-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-- Modifications made by Alexis G.
-------------------------------------------------
local awful = require("awful")
local watch = require("awful.widget.watch")
local json  = require("modules.json")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty") local beautiful = require("beautiful")
local colorize  = require("helpers.ui").colorize_text
local os = os

local HOME_DIR = os.getenv("HOME")
local WIDGET_DIR = HOME_DIR .. '/.config/awesome/modules/weather'
local GET_FORECAST_CMD = [[bash -c "curl -s --show-error -X GET '%s'"]]

local SYS_LANG = os.getenv("LANG"):sub(1, 2)
if SYS_LANG == "C" or SYS_LANG == "C." then
  -- C-locale is a common fallback for simple English
  SYS_LANG = "en"
end
-- default language is English
local LANG = gears.filesystem.file_readable(WIDGET_DIR .. "/" .. "locale/" ..
                    SYS_LANG .. ".lua") and SYS_LANG or "en"
local LCLE = require("modules.weather.locale." .. LANG)


local function show_warning(message)
  naughty.notify {
    preset = naughty.config.presets.critical,
    title = LCLE.warning_title,
    text = message
  }
end

if SYS_LANG ~= LANG then
  show_warning("Your language is not supported yet. Language set to English")
end

local weather_widget = {}
local warning_shown = false
local tooltip = awful.tooltip {
  mode = 'outside',
  preferred_positions = {'bottom'}
}

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

--- Return wind direction as a string
local function to_direction(degrees)
  -- Ref: https://www.campbellsci.eu/blog/convert-wind-directions
  if degrees == nil then return "Unknown dir" end
  local directions = LCLE.directions
  return directions[math.floor((degrees % 360) / 22.5) + 1]
end

--- Convert degrees Celsius to Fahrenheit
local function celsius_to_fahrenheit(c) return c * 9 / 5 + 32 end

-- Convert degrees Fahrenheit to Celsius
local function fahrenheit_to_celsius(f) return (f - 32) * 5 / 9 end

local function gen_temperature_str(temp, fmt_str, show_other_units, units)
  local temp_str = string.format(fmt_str, temp)
  local s = temp_str .. '°' .. (units == 'metric' and 'C' or 'F')

  if (show_other_units) then
    local temp_conv, units_conv
    if (units == 'metric') then
      temp_conv = celsius_to_fahrenheit(temp)
      units_conv = 'F'
    else
      temp_conv = fahrenheit_to_celsius(temp)
      units_conv = 'C'
    end

    local temp_conv_str = string.format(fmt_str, temp_conv)
    s = s .. ' ' .. '(' .. temp_conv_str .. '°' .. units_conv .. ')'
  end
  return s
end

local function uvi_index_color(uvi)
  local color
  if uvi >= 0 and uvi < 3 then color = beautiful.green or '#A3BE8C'
  elseif uvi >= 3 and uvi < 6 then color = beautiful.yellow or '#EBCB8B'
  elseif uvi >= 6 and uvi < 8 then color = '#D08770'
  elseif uvi >= 8 and uvi < 11 then color = beautiful.red or '#BF616A'
  elseif uvi >= 11 then color = '#B48EAD'
  end

  return colorize(uvi, color)
end

local function worker(user_args)

  local args = user_args or {}

  --- Validate required parameters
  if args.coordinates == nil or args.api_key == nil then
    show_warning(LCLE.parameter_warning ..
           (args.coordinates == nil and '<b>coordinates</b>' or '') ..
           (args.api_key == nil and ', <b>api_key</b> ' or ''))
    return
  end

  local coordinates = args.coordinates
  local api_key = args.api_key
  local font_name = args.font_name or beautiful.font:gsub("%s%d+$", "")
  local units = args.units or 'metric'
  local time_format_12h = args.time_format_12h
  local both_units_widget = args.both_units_widget or false
  local show_hourly_forecast = args.show_hourly_forecast
  local show_daily_forecast = args.show_daily_forecast
  local show_current_forecast = args.show_current_forecast
  local icon_pack_name = args.icons or 'weather-underground-icons'
  local icons_extension = args.icons_extension or '.png'
  local timeout = args.timeout or 120

  local ICONS_DIR = WIDGET_DIR .. '/icons/' .. icon_pack_name .. '/'
  local owm_one_cal_api =
    ('https://api.openweathermap.org/data/2.5/onecall' ..
      '?lat=' .. coordinates[1] .. '&lon=' .. coordinates[2] .. '&appid=' .. api_key ..
      '&units=' .. units .. '&exclude=minutely' ..
      (show_hourly_forecast == false and ',hourly' or '') ..
      (show_daily_forecast == false and ',daily' or '') ..
      '&lang=' .. LANG)

  local current_weather_widget = wibox.widget {
    {
      { -- Icon
        {
          id = 'icon',
          resize = true,
          forced_width = 56,
          forced_height = 56,
          widget = wibox.widget.imagebox
        },
        widget = wibox.container.place
      },
      { -- Description
        id     = 'text',
        font   = beautiful.font_reg_xs,
        align  = 'start',
        widget = wibox.widget.textbox,
      },
      forced_width = 300,
      spacing = 15,
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
    -----
    update = function(self, weather)
      self:get_children_by_id('icon')[1]:set_image(
        ICONS_DIR .. icon_map[weather.weather[1].icon] .. icons_extension)

      local textbox = self:get_children_by_id('text')[1]
      local text = LCLE.feels_like .. gen_temperature_str(weather.feels_like, '%.0f', false, units)
        .. ' in Santa\nCruz with ' .. weather.weather[1].description
      textbox:set_markup_silently(colorize(text, beautiful.fg_0))
    end
  }

  local daily_forecast_widget = {
    spacing = 10,
    layout = wibox.layout.flex.horizontal,
    update = function(self, forecast, timezone_offset)
      local count = #self
      for i = 0, count do self[i]=nil end
      for i, day in ipairs(forecast) do
        if i > 5 then break end
        local day_forecast = wibox.widget {
          {
            markup = colorize(os.date('%a', tonumber(day.dt) + tonumber(timezone_offset)), beautiful.fg_0),
            align = 'center',
            font = beautiful.font_reg_s,
            widget = wibox.widget.textbox
          },
          {
            {
              {
                image = ICONS_DIR .. icon_map[day.weather[1].icon] .. icons_extension,
                resize = true,
                forced_width = 48,
                forced_height = 48,
                widget = wibox.widget.imagebox
              },
              align = 'center',
              layout = wibox.container.place
            },
            {
              markup = colorize(day.weather[1].description, beautiful.fg_0),
              font = font_name .. ' 8',
              align = 'center',
              forced_height = 50,
              forced_width = 160,
              widget = wibox.widget.textbox
            },
            layout = wibox.layout.fixed.vertical
          },
          {
            {
              markup = colorize(gen_temperature_str(day.temp.day, '%.0f', false, units), beautiful.fg_0),
              align = 'center',
              font = beautiful.font_reg_xs,
              widget = wibox.widget.textbox
            },
            {
              markup = colorize(gen_temperature_str(day.temp.night, '%.0f', false, units), beautiful.fg_0),
              align = 'center',
              font = beautiful.font_reg_xs,
              widget = wibox.widget.textbox
            },
            layout = wibox.layout.fixed.vertical
          },
          spacing = 8,
          layout = wibox.layout.fixed.vertical
        }
        table.insert(self, day_forecast)
      end
    end
  }

  weather_widget = wibox.widget {
    {
      -- widgets are appended here in update function
      current_weather_widget,
      spacing = 25,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
    set_image = function(self, path)
      -- self:get_children_by_id('icon')[1].image = path
    end,
    set_text = function(self, text)
      -- self:get_children_by_id('txt')[1].text = text
    end,
    is_ok = function(self, is_ok)
      if is_ok then
        self:emit_signal('widget:redraw_needed')
        -- self:get_children_by_id('icon')[1]:set_opacity(1)
        -- self:get_children_by_id('icon')[1]:emit_signal('widget:redraw_needed')
      else
        -- self:get_children_by_id('icon')[1]:set_opacity(0.2)
        -- self:get_children_by_id('icon')[1]:emit_signal('widget:redraw_needed')
        self:emit_signal('widget:redraw_needed')
      end
    end
  }

  local function update_widget(widget, stdout, stderr)
    if stderr ~= '' then
      if not warning_shown then
        if (stderr ~= 'curl: (52) Empty reply from server'
        and stderr ~= 'curl: (28) Failed to connect to api.openweathermap.org port 443: Connection timed out'
        and stderr:find('^curl: %(18%) transfer closed with %d+ bytes remaining to read$') ~= nil
        ) then
          show_warning(stderr)
        end
        warning_shown = true
        widget:is_ok(false)
        tooltip:add_to_object(widget)

        widget:connect_signal('mouse::enter', function() tooltip.text = stderr end)
      end
      return
    end

    warning_shown = false
    tooltip:remove_from_object(widget)
    widget:is_ok(true)

    local result = json.decode(stdout)

    widget:set_image(ICONS_DIR .. icon_map[result.current.weather[1].icon] .. icons_extension)
    widget:set_text(gen_temperature_str(result.current.temp, '%.0f', both_units_widget, units))


    weather_widget.children[1]:reset()

    if show_current_forecast then
      current_weather_widget:update(result.current)
      weather_widget.children[1]:add(current_weather_widget)
    end

    if show_daily_forecast then
      daily_forecast_widget:update(result.daily, result.timezone_offset)
      weather_widget.children[1]:add(daily_forecast_widget)
    end
  end

  watch(
    string.format(GET_FORECAST_CMD, owm_one_cal_api),
    timeout,  -- API limit is 1k req/day; day has 1440 min; every 2 min is good
    update_widget, weather_widget
  )

  return weather_widget
end

return setmetatable(weather_widget, {__call = function(_, ...) return worker(...) end})
