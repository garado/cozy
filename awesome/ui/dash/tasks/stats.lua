
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local dash = require("helpers.dash")
local beautiful = require("beautiful")
local gears = require("gears")
local colorize = require("helpers").ui.colorize_text

return function(task_obj)

  -- █░█ █ 
  -- █▄█ █ 
  local _ui_tag_time_header = wibox.widget({
    markup = colorize("All time", beautiful.dash_header_fg),
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local _ui_tag_time_content = wibox.widget({
    markup = colorize("00:00:00", beautiful.fg),
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local ui_tag_time = wibox.widget({
    _ui_tag_time_header,
    _ui_tag_time_content,
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  })

  -- Assemble the stats widget
  local widget = wibox.widget({
    {
      {
        {
          --dash.widget_header("Stats"),
          ui_tag_time,
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place
    },
    forced_height = dpi(50),
    forced_width = dpi(270),
    bg = beautiful.dash_widget_bg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  -- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
  -- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 
  -- Get total time spent working on a tag
  local function get_tag_time()
    local tag = task_obj.current_tag
    local tag_cmd = "timew sum :all " .. tag .. " | tail -n 2 | head -n 1"
    awful.spawn.easy_async_with_shell(tag_cmd, function(stdout)
      local tag_time = string.gsub(stdout, "[^0-9:]", "")
      task_obj.current_tag_total_time = tag_time
      task_obj:emit_signal("tasks::stats_tag_finished")
    end)
  end

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  -- Every time a new tag is selected, recalculate the tag time
  task_obj:connect_signal("tasks::tag_selected", function()
    get_tag_time()
  end)

  -- When the async call for getting total tag time is finished,
  -- update the UI
  task_obj:connect_signal("tasks::stats_tag_finished", function()
    local time = task_obj.current_tag_total_time or "00:00:00"
    local markup = colorize(time, beautiful.fg)
    _ui_tag_time_content:set_markup_silently(markup)
  end)

  return widget
end
