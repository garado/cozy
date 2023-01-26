
--  █▀▀ █▀█ ▄▀█ █░░ █▀
--  █▄█ █▄█ █▀█ █▄▄ ▄█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local wheader = require("helpers.ui").create_dash_widget_header
local config = require("cozyconf")

local function create_goal(text)
  return wibox.widget({
    markup = colorize(text, beautiful.fg),
    font   = beautiful.base_small_font,
    widget = wibox.widget.textbox,
    align  = "center",
    valign = "center",
  })
end

local widget = wibox.widget({
  {
    wheader("Goals"),
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

local goals_list = config.goals or { "Goal 1", "Goal 2", "Goal 3" }
local w = widget:get_children_by_id("goals")[1]
for i = 1, #goals_list do
  w:add(create_goal(goals_list[i]))
end

return box(widget, dpi(220), dpi(220), beautiful.dash_widget_bg)
