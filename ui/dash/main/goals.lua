
--  █▀▀ █▀█ ▄▀█ █░░ █▀
--  █▄█ █▄█ █▀█ █▄▄ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

local function widget()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("Current Goals", beautiful.dash_header_color),
    font = beautiful.header_font .. "20",
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  local function create_goal(text)
    return wibox.widget({
      markup = helpers.ui.colorize_text(text, beautiful.xforeground),
      font = beautiful.font_name .. "12",
      widget = wibox.widget.textbox,
      align = "center",
      valign = "center",
    })
  end

  local widget = wibox.widget({
    {
      header,
      {
        create_goal("Graduate in December!"),
        create_goal("Get a job!"),
        create_goal("Journal consistently"),
        create_goal("Exercise consistently"),
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
      },
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(220), dpi(220), beautiful.dash_widget_bg)
