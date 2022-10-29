
-- ▀█▀ ▄▀█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█ 

-- Get list of active Taskwarrior tags.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
local tasks_textbox = require("modules.keynav.navitem").Tasks_Textbox
local taskbox = require("modules.keynav.navitem").Taskbox
local Area = require("modules.keynav.area")
local config = require("config")

-- Keyboard navigation
local nav_tags
nav_tags = Area:new({
  name = "tags",
  keys = {
    ["l"] = function()
      local navigator = nav_tags.nav
      navigator:set_area("tasklist")
    end,
  },
  hl_persist_on_area_switch = true,
})

-- Given the output of `task tags`,
-- returns a table of all active Taskwarrior tags and the
-- number of tasks associated with that tag.
local function parse_taskw_tags(stdout)
  local tags = {}

  for line in string.gmatch(stdout, "[^\r\n]+") do
    -- the task count is the string of numbers at end of line
    -- so to get the task count, remove everything except for that
    local count = string.gsub(line, "[^%d+$]", "")

    -- to get tag name, remove the task count
    local name = string.gsub(line, "%s+%d+$", "")

    local tag = {
      ["name"]  = name,
      ["count"] = count,
    }
    table.insert(tags, tag)
  end

  -- the first 2 lines are headers - discard
  table.remove(tags, 1)
  table.remove(tags, 1)

  return tags
end

return function(task_obj)
  local tag_list = wibox.widget({
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  })

  local function create_tag_button(name)
    return wibox.widget({
      markup = helpers.ui.colorize_text(name, beautiful.fg),
      align = "center",
      font = beautiful.font_name .. "11",
      forced_height = dpi(20),
      widget = wibox.widget.textbox,
    })
  end

  local cmd = "task context none ; task tags"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tags = parse_taskw_tags(stdout)
    for i = 1, #tags do
      local tagname = tags[i]["name"]
      local btn = create_tag_button(tagname)
      tag_list:add(btn)

      -- Keyboard navigation
      local nav_tag = tasks_textbox:new(btn)
      function nav_tag:release()
        task_obj.current_tag = tagname
        task_obj.current_project = nil
        task_obj:emit_signal("tasks::tag_selected", tagname)
      end
      nav_tags:append(nav_tag)
    end
    local default_tag = config.task.default_tag
    task_obj.current_tag = default_tag or tags[1]["name"]
    task_obj.current_project = nil
    task_obj:emit_signal("tasks::tag_selected", default_tag)
  end)

  local widget = wibox.widget({
    {
      {
        {
          helpers.ui.create_dash_widget_header("Tags"),
          tag_list,
          spacing = dpi(10),
          forced_width = dpi(150),
          fill_space = false,
          layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(10),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place
    },
    forced_width = dpi(270),
    bg = beautiful.dash_widget_bg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  nav_tags.widget = taskbox:new(widget)
  return widget, nav_tags
end
