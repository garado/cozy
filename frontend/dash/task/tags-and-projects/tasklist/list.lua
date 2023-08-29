
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █▄▄ █▀█ █▀▄ █▄█ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █▄█ █▄▀ ░█░ 

-- Displays a list of tasks for the currently selected tag and project.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local singlesel = require("frontend.widget.single-select")
local task  = require("backend.system.task")
local keybinds = require("frontend.dash.task.tags-and-projects.tasklist.keybinds")
local gen_taskitem = require("frontend.dash.task.gen_taskitem")

local tasklist = {}

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░

tasklist = singlesel({
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
  ---
  keynav = true,
  name = "nav_tasklist",
  scroll = true,
  max_visible_elements = 19
})

tasklist.area.keys = keybinds
tasklist.area.keys["z"] = function() task:emit_signal("details::toggle") end
-- tasklist.area.keys["t"] = function() task:gen_twdeps_img() end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

tasklist.area:connect_signal("area::left", function()
  local c = tasklist.active_element.desc._color
  tasklist.active_element.desc:update_color(c)
end)

task:connect_signal("ready::tasks", function(_, tag, project, tasks)
  tasklist:clear_elements()
  tasklist.tag = tag
  tasklist.project = project

  -- Keep track of the task to show on init
  local idx = 1

  for i = 1, #tasks do
    local taskitem = gen_taskitem(tasks[i])
    tasklist:add_element(taskitem)
    taskitem.data = tasks[i]
    if task.restore and task.restore.id == tasks[i].id then
      idx = i
    end
  end

  tasklist:update_scrollbar()

  -- Initialize first active task
  tasklist.active_element = tasklist.children[idx]
  tasklist.children[idx].selected = true
  tasklist.children[idx]:update()
  tasklist.area:set_active_element_by_index(idx)
  tasklist.children[idx].desc:update_color(tasklist.children[idx].desc._color)
end)

-- Update UI when scrolling
task:connect_signal("selected::task", function()
  tasklist:update()
end)

return tasklist
