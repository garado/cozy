
-- ▀█▀ ▄▀█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█ 
-- Get list of active Taskwarrior tags.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local elevated = require("modules.keynav.navitem").Elevated
local Area = require("modules.keynav.area")

local nav_tags = Area:new({
  name = "tags",
  circular = true,
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
    local name = string.gsub(line, "[%s+%d+$]", "")

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

local tag_list = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local function create_tag_button(name)
  return widgets.button.text.normal({
    text = name,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_opt_btn_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      awesome.emit_signal("tasks::tag_selected", name)
    end
  })
end

local cmd = "task context none ; task tags"
awful.spawn.easy_async_with_shell(cmd, function(stdout)
  local tags = parse_taskw_tags(stdout)
  for i = 1, #tags do
    local btn = create_tag_button(tags[i]["name"])
    tag_list:add(btn)
    nav_tags:append(elevated:new(btn))
  end
end)


local widget = wibox.widget({
  {
    {
      helpers.ui.create_dash_widget_header("Tags"),
      tag_list,
      spacing = dpi(10),
      forced_width = dpi(150),
      fill_space = false,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place
  },
  forced_height = dpi(300),
  forced_width = dpi(350),
  bg = beautiful.dash_widget_bg,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

return function()
  return widget, nav_tags
end
