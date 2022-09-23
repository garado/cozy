
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local widgets = require("ui.widgets")
local os = os

local area = require("modules.keynav.area")
local nav_tasks = area:new({ name = "tasks" })

-- import
local tag_list, nav_tags = require("ui.dash.tasks.tag_list")()
local project_list = wibox.widget({
  forced_num_cols = 3,
  forced_num_rows = 2,
  spacing = dpi(15),
  layout = wibox.layout.grid,
})
require("ui.dash.tasks.project")("mech", project_list)

nav_tasks:append(nav_tags)

-- Assemble
local tasks_dashboard = wibox.widget({
  {
    project_list,
    {
      tag_list,
      fill_space = true,
      layout = wibox.layout.fixed.vertical,
    },
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

-- Change projects shown whenever the tag is changed
awesome.connect_signal("tasks::tag_selected", function(tag)
  require("ui.dash.tasks.project")(tag, project_list)
end)

return function()
  return tasks_dashboard, nav_tasks
end
