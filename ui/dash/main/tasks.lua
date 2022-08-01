
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀
-- ░█░ █▀█ ▄█ █░█ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local gfs = require("gears.filesystem")

local function widget()
  local tasks = wibox.widget({
    {
      font = beautiful.font .. "12",
      markup = helpers.ui.colorize_text("No tasks found.\nEither you're on vacation or this script is broken.", beautiful.dash_widget_fg),
      widget = wibox.widget.textbox,
      align = "center",
      valign = "center",
    },
    widget = wibox.container.place,
  })

  local contents = wibox.widget({
    { -- header
      {
        markup = helpers.ui.colorize_text("Tasks", beautiful.dash_header_color),
        font = beautiful.header_font .. "20",
        widget = wibox.widget.textbox,
        align = "center",
        valign = "center",
      },
      margins = dpi(5),
      widget = wibox.container.margin,
    }, -- end header
    tasks,
    layout = wibox.layout.fixed.vertical,
  })

  widget = wibox.widget({
    contents,
    margins = dpi(5),
    widget = wibox.container.margin,
  })

  local function update_tasks()
    awful.spawn.easy_async_with_shell(
      [[
        $HOME/.config/awesome/utils/dash/main/tasks/print_tasks 
      ]],
      function(stdout)
        local stdout = helpers.ui.colorize_text(stdout, beautiful.dash_widget_fg)
        tasks:get_children()[1]:set_markup(stdout)
      end
    )
  end

  -- This signal is emitted in a taskwarrior hook
  -- See scripts in awesome/utils/dash/main/tasks/
  awesome.connect_signal("widget::update_tasks", function()
    update_tasks()
  end)
  
  update_tasks()

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(220), dpi(210), beautiful.dash_widget_bg)

