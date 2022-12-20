
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox     = require("wibox")
local xresources = require("beautiful.xresources")
local area      = require("modules.keynav.area")
local navtask   = require("modules.keynav.navitem").Task
local colorize  = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date
local dpi = xresources.apply_dpi

local task = require("core.system.task")

-- local overflow_top, overflow_bottom = {}

-- █▄▀ █▀▀ █▄█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄  
-- █░█ ██▄ ░█░ █▄█ █▄█ █▀█ █▀▄ █▄▀  

local nav_tasklist
nav_tasklist = area:new({
  name = "tasklist",
  circular = true,
  keys = require("ui.dash.task.keys.tasklist")
})

-- █░█ █
-- █▄█ █

local tasklist = wibox.widget({
  spacing = dpi(8),
  layout = wibox.layout.flex.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

--- Creates a single task wibox.
local function create_task_wibox(task_table)
  local desc  = task_table["description"]
  local due   = task_table["due"] or ""
  local start = task_table["start"]

  desc = desc:gsub("%^l", string.upper)
  local taskname_color = start and beautiful.green or beautiful.fg
  local taskname = wibox.widget({
    markup = colorize(desc, taskname_color),
    font = beautiful.font_name .. "12",
    ellipsize = "end",
    widget = wibox.widget.textbox,
  })

  local due_text, due_color = format_due_date(due)
  local due_ = wibox.widget({
    markup = colorize(due_text, due_color or beautiful.fg_sub),
    font = beautiful.font_name .. "12",
    halign = "right",
    align = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    taskname,
    nil,
    due_,
    forced_height = dpi(20),
    layout = wibox.layout.align.horizontal,
  })
end

local function create_task_nav(task_wibox, _task, index)
  local ntask = navtask:new(task_wibox, nil, _task["id"])
  ntask.index = index

  function ntask:select_on()
    self.selected = true
    local text = self.widget.children[1]
    text.font = beautiful.font_name .. "Bold 12"
    task:set_focused_task(_task, self.index)
  end

  function ntask:select_off()
    self.selected = false
    local text = self.widget.children[1]
    text.font = beautiful.font_name .. "12"
  end

  return ntask
end

local function add_task_wibox(task_wibox)
  tasklist:add(task_wibox)
  -- Scrollbox
  -- if #tasklist.children < task_obj.max_tasks_shown then
  --   tasklist:add(task)
  -- else
  --   table.insert(overflow_bottom, task)
  -- end
end

local function remove_task_wibox(index)
  tasklist:remove(index)
end

-- Handles switching to the correct index after redrawing because a task
-- was added/deleted/completed
local function update_wibox_index()
  if task.need_switch_index then
    task:emit_signal("ui::switch_tasklist_index", task.switch_index)
    task.need_switch_index = false
  end
end

----

--- Draw all tasks for a project
task:connect_signal("update::tasks", function(_, tag, project)
  nav_tasklist:remove_all_items()
  nav_tasklist:reset()
  tasklist:reset()

  local json_tasklist = task:get_pending_tasks()
  for i = 1, #json_tasklist do
    local task_wibox = create_task_wibox(json_tasklist[i])
    local ntask = create_task_nav(task_wibox, json_tasklist[i], i)

    nav_tasklist:append(ntask)
    add_task_wibox(task_wibox)
  end -- end for

  update_wibox_index()
end)

--- Add a single task to the task list
-- Note: this is called *after* task has been added to data table,
-- so #get_pending_tasks is in fact the correct index
task:connect_signal("tasklist::add", function(_, new_task)
  local task_wibox = create_task_wibox(new_task)
  local index = #task:get_pending_tasks()
  local ntask = create_task_nav(task_wibox, new_task, index)
  nav_tasklist:append(ntask)
  add_task_wibox(task_wibox)
  update_wibox_index()
  nav_tasklist:set_curr_item(index)
end)

--- Remove a task from the task list and task keynav hierarchy
-- Note: this is called *after* task has been removed from data table
task:connect_signal("tasklist::remove", function()
  local index_to_remove = task:get_focused_task_index()
  remove_task_wibox(index_to_remove)
  nav_tasklist:remove_index(index_to_remove)
  update_wibox_index()

  -- Cursor will stay in the same position post removal
  nav_tasklist:set_curr_item(index_to_remove)

  -- The self.index field is used to set task.focused_task_index
  -- whenever a new task navitem is selected
  -- Must update these indices when you alter the order
  for i = index_to_remove, #nav_tasklist.items do
    nav_tasklist.items[i].index = i
  end
end)

return function()
  return tasklist, nav_tasklist
end
