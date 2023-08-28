
-- █░█░█ █▀▀ ▄▀█ ▀█▀ █░█ █▀▀ █▀█
-- ▀▄▀▄▀ ██▄ █▀█ ░█░ █▀█ ██▄ █▀▄

-- A clone of the Timepage iOS weather widget

local beautiful  = require("beautiful")
local ui         = require("utils.ui")
local dpi        = ui.dpi
local gfs        = require("gears.filesystem")
local gcolor     = require("gears.color")
local wibox      = require("wibox")
local weather    = require("backend.system.openweather")

local ICONS_PATH = gfs.get_configuration_dir() .. "theme/assets/weather/"
local DEGREE     = "°"

--- @function gen_forecast_entry
-- @brief Helper function to create lil forecast widget
local function gen_forecast_entry(data, is_current)
  is_current = is_current or false

  local icon = weather.icon_map[data.weather[1].icon]:gsub(" ", "-")
  local path = ICONS_PATH .. icon .. ".png"
  local temp = math.floor(data.main.feels_like)
  local time = is_current and "Now" or os.date("%I:%M%p", data.dt)

  return wibox.widget({
    {
      {
        image = gcolor.recolor_image(path, beautiful.primary[400]),
        forced_width = dpi(40),
        forced_height = dpi(40),
        widget = wibox.widget.imagebox,
      },
      widget = wibox.container.place,
    },
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
  text = "83% humidity and moderate wind in Santa Cruz with no rain",
  width = dpi(250),
  wrap = "word",
  ellipsize = "none",
})

local high = wibox.widget({
  ui.textbox({
    text = "H",
    font = beautiful.font_light_m,
  }),
  ui.textbox({
    text = "70" .. DEGREE,
    font = beautiful.font_bold_m,
    width = dpi(32),
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
    text = "70" .. DEGREE,
    font = beautiful.font_bold_m,
    width = dpi(32),
  }),
  spacing = dpi(2),
  layout = wibox.layout.fixed.horizontal,
})

local forecast = wibox.widget({
  layout = wibox.layout.flex.horizontal,
})

local widget = wibox.widget({
  {
    summary,
    nil,
    {
      high,
      low,
      spacing = dpi(5),
      layout = wibox.layout.fixed.horizontal,
    },
    forced_width = dpi(2000), -- Beeg number to take all available space
    layout = wibox.layout.align.horizontal,
  },
  forecast,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

weather:fetch_current()

weather:connect_signal("ready::current", function(_, data)
  forecast:add(gen_forecast_entry(data, true))
  summary:update_text(data.main.humidity .. "% humidity in " .. data.name .. " with " .. data.weather[1].description)
  weather:fetch_forecast()
end)

weather:connect_signal("ready::forecast", function(_, data)
  for i = 1, #data.list do
    forecast:add(gen_forecast_entry(data.list[i]))
  end
end)

return ui.dashbox_v2(widget)
