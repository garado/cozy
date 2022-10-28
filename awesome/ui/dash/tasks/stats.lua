
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- Background info: if my task group is 'Class' and I have a project for
-- that group called 'Assignment1', then in Timew I track the tags 'Class'
-- and 'Class:Assignment1'
-- This way I can easily track time per tag as well as time per project

local awful = require("awful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
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

  local _ui_proj_time_header = wibox.widget({
    markup = colorize("Project time", beautiful.dash_header_fg),
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local _ui_proj_time_content = wibox.widget({
    markup = colorize("00:00:00", beautiful.fg),
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local ui_proj_time = wibox.widget({
    _ui_proj_time_header,
    nil,
    _ui_proj_time_content,
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  })

  -- Assemble the stats widget
  local widget = wibox.widget({
    {
      {
        {
          --dash.widget_header("Stats"),
          {
            ui_tag_time,
            widget = wibox.container.place,
          },
          {
            ui_proj_time,
            widget = wibox.container.place,
          },
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
  --- Get total time spent working on a project
  -- The output of the Timewarrior command looks like:
  --                                  65:00:23
  -- (The important part is that it starts with a ton of spaces)
  -- If there is no Timewarrior data then the output looks like:
  -- No filtered data found tagged with Tag:Project.
  local function get_proj_time()
    local curr_tag = task_obj.current_tag
    local curr_proj = task_obj.current_project
    if not curr_proj then return end
    local tag = curr_tag .. ":" .. curr_proj
    local cmd = "timew sum :all " .. tag .. " | tail -n 2 | head -n 1"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      -- If first char is a space, then there was (probably?) a valid
      -- Timewarrior output
      local first_char = string.sub(stdout, 1, 1)
      local proj_time
      if first_char ~= " " and first_char ~= "\t" then
        proj_time = ""
      else
        proj_time = string.gsub(stdout, "[^0-9:]", "")
      end
      task_obj.current_proj_total_time = proj_time
      task_obj:emit_signal("tasks::stats_tag_finished", "total_proj")
    end)
  end

  -- Get total time spent working on a tag
  local function get_tag_time()
    local tag = task_obj.current_tag
    local tag_cmd = "timew sum :all " .. tag .. " | tail -n 2 | head -n 1"
    awful.spawn.easy_async_with_shell(tag_cmd, function(stdout)
      -- If first char is a space, then there was (probably?) a valid
      -- Timewarrior output
      local first_char = string.sub(stdout, 1, 1)
      local tag_time
      if first_char ~= " " and first_char ~= "\t" then
        tag_time = ""
      else
        tag_time = string.gsub(stdout, "[^0-9:]", "")
      end
      task_obj.current_tag_total_time = tag_time
      task_obj:emit_signal("tasks::stats_tag_finished", "total_tag")
      get_proj_time()
    end)
  end

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  -- Every time a new tag is selected, recalculate the tag time
  task_obj:connect_signal("tasks::tag_selected", function()
    get_tag_time()
  end)

  task_obj:connect_signal("tasks::project_selected", function()
    get_proj_time()
  end)

  -- When an async call for getting stats is finished,
  -- update the UI accordingly
  task_obj:connect_signal("tasks::stats_tag_finished", function(_, type)
    if type == "total_tag" then
      local time = task_obj.current_tag_total_time or "00:00:00"
      local markup = colorize(time, beautiful.fg)
      _ui_tag_time_content:set_markup_silently(markup)
    end

    if type == "total_proj" then
      local time = task_obj.current_proj_total_time
      if not time or time == ":" or time == "" then time = "00:00:00" end
      local markup = colorize(time, beautiful.fg)
      _ui_proj_time_content:set_markup_silently(markup)
    end
  end)

  return widget
end
