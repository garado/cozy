
--  █▀▀ █▀█ ▄▀█ █░░ █▀
--  █▄█ █▄█ █▀█ █▄▄ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local config = require("config")

local function widget()

  local function create_goal(text)
    return wibox.widget({
      markup = helpers.ui.colorize_text(text, beautiful.fg),
      font = beautiful.font_name .. "12",
      widget = wibox.widget.textbox,
      align = "center",
      valign = "center",
    })
  end

  local widget = wibox.widget({
    {
      helpers.ui.create_dash_widget_header("Current Goals"),
      {
        id = "goals",
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical,
      },
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
  
  local goals_list = config.goals
  local w = widget:get_children_by_id("goals")[1]
  for _,v in ipairs(goals_list) do
    w:add(create_goal(v))
  end

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(220), dpi(220), beautiful.dash_widget_bg)
