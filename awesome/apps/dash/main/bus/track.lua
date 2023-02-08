
-- █░█ █ █▀▀ █░█░█ ▀    ▀█▀ █▀█ ▄▀█ █▀▀ █▄▀ 
-- ▀▄▀ █ ██▄ ▀▄▀▄▀ ▄    ░█░ █▀▄ █▀█ █▄▄ █░█ 

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears   = require("gears")
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local buscore = require("core.web.bus")
local core    = require("helpers.core")
local keynav  = require("modules.keynav")

local SELECT = 1
local TRACK  = 2

local header = wibox.widget({
  markup = ui.colorize("Tracking the damn bus", beautiful.fg_0),
  font   = beautiful.font_reg_m,
  align  = "center",
  widget = wibox.widget.textbox,
  -----
  update = function(self)
    local text = "Tracking arrivals to " .. buscore.route_info.from
    local mkup = ui.colorize(text, beautiful.fg_0)
    self:set_markup_silently(mkup)
  end
})

local last_updated = wibox.widget({
  align  = "center",
  font   = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
  -----
  update = function(self)
    local text = "Last updated " .. buscore.last_updated
    local mkup = ui.colorize(text, beautiful.fg_0)
    self:set_markup_silently(mkup)
  end
})

local stop_button = ui.simple_button({
  text = "Stop tracking the damn bus",
  bg   = beautiful.bg_2,
  font = beautiful.font_light_s,
  margins = {
    left   = dpi(15),
    right  = dpi(15),
    top    = dpi(10),
    bottom = dpi(10),
  }
})

local nav_stop_button = keynav.navitem.background({
  widget  = stop_button:get_bg_wibox(),
  bg_off  = beautiful.bg_2,
  bg_on   = beautiful.bg_4,
  release = function()
    buscore:emit_signal("view::switch", SELECT)
    buscore:emit_signal("tracking::stop")
  end,
})

local placeholder = wibox.widget({
  markup = ui.colorize("Loading...", beautiful.fg_0),
  font   = beautiful.font_light_s,
  widget = wibox.widget.textbox,
})

-- Layoutbox that arrivals will be appended to
local arrivals = wibox.widget({
  spacing = dpi(8),
  layout  = wibox.layout.fixed.vertical,
  -----
  set_placeholder = function(self)
    self:add(placeholder)
  end,
})

local function update_arrivals()
  arrivals:reset()
  last_updated:update()

  if #buscore.data > 1 then arrivals:reset() end
  for i = 1, #buscore.data do
    local info = buscore.data[i]
    local time_until = info[buscore.MINUTES_TO_ARRIVAL] .. " min"
    local route_name = info[buscore.ROUTE_NAME]
    local metro_arr  = info[buscore.METRO_ARR]
    local scheduled  = info[buscore.SCHEDULED_TIME]

    local metro_text = ""
    if info[buscore.METRO_ARR] then
      metro_text = " (arr. " .. info[buscore.METRO_ARR].. ")"
    end

    local arrival = wibox.widget({
      {
        forced_width = dpi(50),
        markup = ui.colorize("   " .. route_name, beautiful.fg_0),
        align  = "left",
        font   = beautiful.font_med_s,
        widget = wibox.widget.textbox,
      },
      nil,
      {
        { -- in x min
          markup = ui.colorize("in " .. time_until, beautiful.fg_0),
          align  = "end",
          font   = beautiful.font_light_s,
          widget = wibox.widget.textbox,
        },
        { -- arrival to metro
          markup = ui.colorize(metro_text, beautiful.fg_1),
          align  = "end",
          font   = beautiful.font_light_s,
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
      },
      fill_space = false,
      layout  = wibox.layout.fixed.horizontal,
    })

    arrivals:add(arrival)
  end
end

-----

local view_track = wibox.widget({
  header,
  {
    arrivals,
    widget = wibox.container.place,
  },
  last_updated,
  stop_button,
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

local nav_track = keynav.area({
  name = "bus_track",
  children = {
    nav_stop_button,
  }
})

buscore:connect_signal("view::switch", function(_, view)
  if view ~= TRACK then return end
  header:update()
  arrivals:reset()
  arrivals:set_placeholder()
end)

buscore:connect_signal("data::ready", update_arrivals)

return function()
  return view_track, nav_track
end
