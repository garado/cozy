
-- █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█
-- ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄

-- A clone of the Timepage iOS weather widget.
-- Fetches data on startup and then reads current weather every hour and
-- forecast every 3 hours after that.

local beautiful = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local weather = require("backend.system.openweather")
local os = os

local DEGREE = "°"
local SECONDS_PER_HOUR = 60 * 60

if not weather then
  return ui.dashbox_v2(ui.placeholder("OpenWeather API key not provided."))
end

--- @function gen_forecast_entry
-- @brief Helper function to create lil forecast widget
local function gen_forecast_entry(data)
  local temp = math.floor(data.main.feels_like)
  local time = os.date("%I:%M%p", data.dt)

  local icon = ui.textbox({
    text = weather.icon_map[data.weather[1].icon]:gsub(" ", "-"),
    font = beautiful.font_reg_xl,
    align = "center",
    color = beautiful.primary[400],
  })

  return wibox.widget({
    wibox.container.place(icon),
    ui.textbox({
      text = temp .. DEGREE,
      align = "center",
      font = beautiful.font_bold_m,
    }),
    ui.textbox({
      text = time,
      align = "center",
      color = beautiful.neutral[300],
      font = beautiful.font_reg_xs,
    }),
    spacing = dpi(3),
    layout = wibox.layout.fixed.vertical,
  })
end

local summary = ui.textbox({
  text = "- and -% humidity in - with - rain",
  width = dpi(220),
  wrap = "word",
  ellipsize = "none",
})

local high = wibox.widget({
  ui.textbox({
    text = "H",
    font = beautiful.font_light_m,
  }),
  ui.textbox({
    text = "-",
    font = beautiful.font_bold_m,
  }),
  spacing = dpi(2),
  layout = wibox.layout.fixed.horizontal,
})

local low = wibox.widget({
  ui.textbox({
    text = "L",
    font = beautiful.font_light_m,
  }),
  ui.textbox({
    text = "-",
    font = beautiful.font_bold_m,
  }),
  spacing = dpi(2),
  layout = wibox.layout.fixed.horizontal,
})

local top = wibox.widget({
  {
    summary,
    forced_height = dpi(35),
    widget = wibox.container.place,
  },
  nil,
  {
    high,
    low,
    spacing = dpi(5),
    forced_width = dpi(110),
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(10),
  forced_width = dpi(2000), -- Beeg number to take all available space
  layout = wibox.layout.align.horizontal,
})

local forecast = wibox.widget({
  layout = wibox.layout.flex.horizontal,
})

local forecast_failure = ui.placeholder("Failure to obtain forecast.")

local widget = wibox.widget({
  top,
  forecast,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})



-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

weather:fetch_current()
weather:fetch_forecast()

-- Set up timer to re-fetch data when necessary.
local current_timer = gears.timer {
  timeout = SECONDS_PER_HOUR,
  autostart = false,
  call_now = false,
  callback = function() weather:fetch_current() end,
}

local forecast_timer = gears.timer {
  timeout = 3 * SECONDS_PER_HOUR,
  autostart = false,
  call_now = false,
  callback = function() weather:fetch_forecast() end
}

weather:connect_signal("failure::current", function()
  top.visible = false
  widget.spacing = 0
  current_timer:start()
end)

weather:connect_signal("failure::forecast", function()
  forecast:reset()
  forecast:add(forecast_failure)
  forecast_timer:start()
end)

weather:connect_signal("ready::current", function(_, data)
  top.visible = true
  widget.spacing = dpi(20)

  local temp = math.floor(data.main.feels_like)..DEGREE
  summary:update_text("Feels like "..temp.." with "..data.main.humidity .. "% humidity and " ..
                      data.weather[1].description .. " in " .. data.name)
  low.children[2]:update_text(math.floor(data.main.temp_min) .. DEGREE)
  high.children[2]:update_text(math.floor(data.main.temp_max) .. DEGREE)

  current_timer:start()
end)

weather:connect_signal("ready::forecast", function(_, data)
  forecast:reset()
  for i = 1, #data.list do
    forecast:add(gen_forecast_entry(data.list[i]))
  end
  forecast_timer:start()
end)

return ui.dashbox_v2(widget)
