
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gobject = require("gears.object")
local area = require("modules.keynav.area")

-- gears.object that modules use to communicate with each other.
-- it emits/connects to signals and also holds state variables
local task_obj = gobject{}
task_obj.current_tag  = "Cozy"

-- Import modules
local tag_list, nav_tags     = require("ui.dash.tasks.tags")(task_obj)
local overview, nav_overview = require("ui.dash.tasks.project_overview")(task_obj)
local projects, nav_projects = require("ui.dash.tasks.project_list")(task_obj)
local stats   = require("ui.dash.tasks.stats")(task_obj)
local prompt  = require("ui.dash.tasks.prompt")(task_obj)
require("ui.dash.tasks.parser")(task_obj)

-- Keyboard navigation
local nav_tasks = area:new({ name = "tasks" })
local nav_sidebar = area:new({ name = "sidebar", circular = true })
nav_sidebar:append(nav_tags)
nav_sidebar:append(nav_projects)
nav_tasks:append(nav_sidebar)
nav_tasks:append(nav_overview)

-- Having to define this twice (here and in keygrabber) seems clumsy,
-- but currently the only way to get these commands to work everywhere in
-- task manager (not just in project_overview)
-- I'll refactor another day
local function request(type)
  task_obj:emit_signal("tasks::input_request", type)
end

nav_sidebar.keys ={
  ["H"] = {["function"] = request, ["args"] = "help"},    -- show help menu
  ["a"] = {["function"] = request, ["args"] = "add"},     -- add new task
  ["/"] = {["function"] = request, ["args"] = "search"},  -- search
}

-- Switches to a specific index in the task overview list.
-- Emitted after task search.
task_obj:connect_signal("tasks::switch_to_task_index", function(_, index)
  nav_overview:set_curr_item(index)
  nav_tasks.nav:set_area("overview")
end)

-- Assemble UI
local sidebar = wibox.widget({
  tag_list,
  projects,
  stats,
  spacing = dpi(15),
  forced_height = dpi(730),
  layout = wibox.layout.ratio.vertical,
})
sidebar:adjust_ratio(2, unpack({0.4, 0.4, 0.2}))

local tasks_dashboard = wibox.widget({
  {
    sidebar,
    {
      {
        overview,
        prompt,
        layout = wibox.layout.fixed.vertical,
      },
      left = dpi(15),
      right = dpi(20),
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
