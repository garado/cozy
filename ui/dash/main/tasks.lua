
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀
-- ░█░ █▀█ ▄█ █░█ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local utils = require("utils")

local function widget()
  local tasks = wibox.widget({
    {
      font = beautiful.font .. "12",
      widget = wibox.widget.textbox,
    },
    widget = wibox.container.place,
  })

  awful.spawn.easy_async_with_shell(
    [[
      $HOME/.dotfiles/config/.config/eww/dash/scripts/print_tasks
    ]],
    function(stdout)
      local stdout = utils.ui.colorize_text(stdout, beautiful.xforeground)
      tasks:get_children()[1]:set_markup(stdout)
    end
  )

  local contents = wibox.widget({
    { -- header
      {
        markup = utils.ui.colorize_text("Quests", beautiful.nord9),
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

  return widget
end

return utils.ui.create_boxed_widget(widget(), dpi(320), dpi(210), beautiful.background_med)


