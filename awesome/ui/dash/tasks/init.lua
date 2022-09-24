
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local area = require("modules.keynav.area")

-- gears.object that modules use to communicate
-- with each other
local task_obj = gobject{}
task_obj.current_tag  = "Cozy"
task_obj.current_proj = "General"

-- Import modules
local tag_list, nav_tags     = require("ui.dash.tasks.tags")(task_obj)
local overview, nav_overview = require("ui.dash.tasks.overview")(task_obj)
local projects, nav_projects = require("ui.dash.tasks.projects")(task_obj)
require("ui.dash.tasks.parser")(task_obj)

-- Keyboard navigation
local nav_tasks = area:new({ name = "tasks" })
nav_tasks:append(nav_tags)
nav_tasks:append(nav_overview)
nav_tasks:append(nav_projects)

-- Assemble UI
local tasks_dashboard = wibox.widget({
  {
    {
      tag_list,
      layout = wibox.layout.fixed.vertical,
    },
    {
      overview,
      left = dpi(15),
      right = dpi(20),
      widget = wibox.container.margin,
    },
    {
      projects,
      widget = wibox.container.margin,
    },
    spacing = dpi(15),
    layout = wibox.layout.align.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

return function()
  return tasks_dashboard, nav_tasks
end
