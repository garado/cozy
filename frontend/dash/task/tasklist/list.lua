
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █▄▄ █▀█ █▀▄ █▄█ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █▄█ █▄▀ ░█░ 

-- Displays a list of tasks for the currently selected tag and project.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gears = require("gears")
local singlesel = require("frontend.widget.single-select")
local strutil = require("utils.string")
local task  = require("backend.system.task")
local keybinds = require("frontend.dash.task.tasklist.keybinds")

local tasklist = {}

--- @function gen_taskitem
-- @brief Generate a single tasklist entry.
local function gen_taskitem(t)
  -- Determine colors for task name, due date
  local text_color = beautiful.fg
  local due_color  = beautiful.neutral[300]

  local due_str, is_overdue
  if t.due then
    due_str, is_overdue = strutil.iso_to_relative(t.due)
  end

  if is_overdue or t.urgency > 9 then
    due_color  = beautiful.red[400]
    text_color = beautiful.red[400]
  end

  if t.start then
    text_color = beautiful.green[400]
  end

  -- Wibox for task name
  local desc = ui.textbox({
    text  = t.description,
    width = dpi(750),
    color = text_color
  })

  -- Indicator icon shows which task is selected
  local indicator = wibox.widget({
    forced_height = dpi(3),
    forced_width  = dpi(3),
    bg = beautiful.neutral[800],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
  })

  -- Due date
  local due = ui.textbox({
    text  = t.due and due_str or "no due date",
    color = due_color
  })

  local taskitem = wibox.widget({
    {
      indicator,
      desc,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    nil,
    due,
    layout = wibox.layout.align.horizontal,
    -----
    desc = desc, -- need an easy-access reference for later
  })

  taskitem:connect_signal("mouse::enter", function(self)
    self:emit_signal("button::press")
    task.active_task = self.data
    task.active_task_ui = desc
    task:emit_signal("selected::task", self.data)
  end)

  taskitem:connect_signal("mouse::leave", function(self) self:update() end)

  function taskitem:update()
    local c = self.selected and beautiful.primary[400] or desc._color
    indicator.bg = self.selected and beautiful.fg or beautiful.neutral[800]
    desc:update_color(c)
  end

  return taskitem
end

-- TODO: this whole thing
--- @function gen_scrollbar
local function gen_scrollbar()
end

tasklist = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

tasklist = singlesel({ layout = tasklist, keynav = true, name = "nav_tasklist" })

tasklist.area:connect_signal("area::left", function()
  tasklist.active_element.desc:update_color(beautiful.fg)
end)

tasklist.area.keys = keybinds
tasklist.area.keys["z"] = function() task:emit_signal("details::toggle") end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

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

  -- Initialize first active task
  tasklist.active_element = tasklist.children[idx]
  tasklist.children[idx].selected = true
  tasklist.children[idx]:update()
  tasklist.area:set_active_element_by_index(idx)
  tasklist.children[idx].desc:update_color(tasklist.children[idx].desc._color)
end)

return tasklist
