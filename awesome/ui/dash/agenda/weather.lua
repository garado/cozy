
-- █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄ 

-- Note: weather widget has been modified to fit into the dashboard
-- It is optimized for temperatures that are never sub-zero

local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local colorize  = require("helpers.ui").colorize_text
local weather = require("modules.weather.weather")
local config = require("config")

local weather_widget = weather({
  api_key = config.weather.api_key,
  coordinates = config.weather.coordinates,
  time_format_12h = true,
  units = 'imperial',
  both_units_widget = false,
  font_name = beautiful.base_font_name,
  icons = 'pixels',
  icons_extension = '.png',
  show_daily_forecast = true,
  show_current_forecast = false,
  timeout = 10 * 60, -- 10 min refresh rate
})

local widget = wibox.widget({
  wibox.widget({
    markup = colorize("Forecast", beautiful.fg),
    align = "center",
    valign = "center",
    font = beautiful.alt_large_font,
    widget = wibox.widget.textbox,
  }),
  {
    weather_widget,
    valign = 'center',
    widget = wibox.container.place,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

return widget
