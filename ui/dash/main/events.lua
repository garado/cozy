
-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▀
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

local function widget()
  local events = wibox.widget({
    {
      font = beautiful.font .. "12",
      widget = wibox.widget.textbox,
    },
    widget = wibox.container.place,
  })

  local contents = wibox.widget({
    { -- header
      {
        markup = helpers.ui.colorize_text("Events", beautiful.dash_header_color),
        --font = beautiful.font .. "20",
        font = beautiful.header_font .. "20",
        widget = wibox.widget.textbox,
        align = "center",
        valign = "center",
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    }, -- end header
    events,
    layout = wibox.layout.fixed.vertical,
  })

  widget = wibox.widget({
    contents,
    margins = dpi(5),
    widget = wibox.container.margin,
  })
  
  local function calendar()
    awful.spawn.easy_async_with_shell(
      [[
        cat $HOME/.cache/awesome/calendar/agenda
      ]],
      function(stdout)
        local stdout = helpers.ui.colorize_text(stdout, beautiful.dash_widget_fg)
        events:get_children()[1]:set_markup(stdout)
      end
    )
  end
  
  awesome.connect_signal("widget::calendar_update", function()
    calendar()
  end)
  
  calendar()

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(220), dpi(210), beautiful.dash_widget_bg)

