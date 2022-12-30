
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

-- List of task names & scrollbar

local beautiful   = require("beautiful")
local wibox       = require("wibox")
local xresources  = require("beautiful.xresources")
local gears       = require("gears")
local area        = require("modules.keynav.area")
local navtask     = require("modules.keynav.navitem").Task
local colorize    = require("helpers.ui").colorize_text
local remove_pango    = require("helpers.dash").remove_pango
local format_due_date = require("helpers.dash").format_due_date
local dpi   = xresources.apply_dpi
local task  = require("core.system.task")
local debug = require("core.debug")

-- Scroll stuff
local MAX_TASKS_SHOWN = 21
local MAX_TASKLIST_HEIGHT = dpi(580)
local first_position_index = 1

-- These overflow containers are for ui elements only
-- The keynav elements do not have containers - they are always present
local overflow_top    = {}
local overflow_bottom = {}

local function total_overflow()
  return #overflow_top + #overflow_bottom
end

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

-- Maximum and handle_width are set later
local scrollbar = wibox.widget({
  {
    id            = "bar",
    value         = 0,
    forced_height = dpi(5), -- since it's rotated, this is width
    bar_color     = beautiful.task_scrollbar_bg,
    handle_color  = beautiful.task_scrollbar_fg,
    handle_border_width = 0,
    bar_shape     = gears.shape.rounded_rect,
    widget        = wibox.widget.slider,
  },
  direction = "west",
  widget    = wibox.container.rotate,
})

local scrollbar_cont = wibox.widget({
  scrollbar,
  right   = dpi(15),
  visible = total_overflow() > 0,
  widget  = wibox.container.margin,
})

local tasklist_widget = wibox.widget({
  {
    scrollbar_cont,
    tasklist,
    layout = wibox.layout.align.horizontal,
  },
  height = MAX_TASKLIST_HEIGHT,
  widget = wibox.container.constraint,
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
    id = "description",
    markup = colorize(desc, taskname_color),
    font = beautiful.base_small_font,
    ellipsize = "end",
    widget = wibox.widget.textbox,
  })

  local due_text, due_color = format_due_date(due)
  local due_ = wibox.widget({
    id = "due",
    markup = colorize(due_text, due_color or beautiful.fg_sub),
    font = beautiful.base_small_font,
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
  local ntask = navtask:new(task_wibox.children[1], nil, _task["id"])
  ntask.index = index

  function ntask:select_on()
    self.selected = true
    local text = remove_pango(self.widget.text)
    local markup = colorize(text, beautiful.main_accent)
    self.widget:set_markup_silently(markup)
    task:set_focused_task(_task, self.index)
    task:emit_signal("selected::task")
  end

  function ntask:select_off()
    self.selected = false
    local text = remove_pango(self.widget.text)
    local markup = colorize(text, beautiful.fg)
    self.widget:set_markup_silently(markup)
  end

  return ntask
end

-- Handles switching to the correct index after redrawing because a task
-- was added/deleted/completed
local function update_wibox_index()
  if task.need_switch_index then
    task:emit_signal("ui::switch_tasklist_index", task.switch_index)
    task.need_switch_index = false
  end
end

-- █▀ █▀▀ █▀█ █▀█ █░░ █░░ █▄▄ ▄▀█ █▀█ 
-- ▄█ █▄▄ █▀▄ █▄█ █▄▄ █▄▄ █▄█ █▀█ █▀▄ 
local function scroll_up()
  local bar = scrollbar.children[1]
  bar.value = bar.value - 1
  first_position_index = first_position_index - 1

  -- For scroll up, the last task gets hidden
  -- Prepend to overflow_bottom buffer
  local last_task_shown
  if #tasklist.children > (first_position_index + 20) then
    last_task_shown = first_position_index + MAX_TASKS_SHOWN - 1
  else
    last_task_shown = #tasklist.children
  end
  table.insert(overflow_bottom, 1, tasklist.children[last_task_shown])
  tasklist:remove(#tasklist.children)

  -- Prepend last task from overflow_top to tasklist 
  tasklist:insert(1, overflow_top[#overflow_top])
  table.remove(overflow_top, #overflow_top)
end

local function scroll_down()
  local bar = scrollbar.children[1]
  bar.value = bar.value + 1
  first_position_index = first_position_index + 1

  -- When scrolling down, the first visible task gets hidden
  -- Append to overflow_top buffer
  overflow_top[#overflow_top+1] = tasklist.children[1]
  tasklist:remove(1)

  -- Append the first task from overflow_bottom 
  tasklist:add(overflow_bottom[1])
  table.remove(overflow_bottom, 1)
end

local function jump_top()
  while #overflow_top > 0 do
    scroll_up()
  end

  nav_tasklist:set_curr_item(#overflow_top + 1)
end

local function jump_end()
  -- is this necessary? idk
  nav_tasklist:set_curr_item(#task:get_pending_tasks() - #overflow_bottom)

  while #overflow_bottom > 0 do
    scroll_down()
  end
  nav_tasklist:set_curr_item(#task:get_pending_tasks())
end

local function update_scrollbar(num_tasks)
  if not num_tasks then return end
  local scrollbar_height = ((MAX_TASKS_SHOWN / num_tasks) * MAX_TASKLIST_HEIGHT)
  local maximum = (total_overflow() > 1 and total_overflow()) or 1

  local bar = scrollbar.children[1]
  bar.handle_width  = scrollbar_height
  bar.maximum       = maximum
  scrollbar_cont.visible  = true
end


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

--- Draw all tasks for a project
task:connect_signal("update::tasks", function()
  nav_tasklist:remove_all_items()
  nav_tasklist:reset()
  tasklist:reset()
  overflow_top = {}
  overflow_bottom = {}

  local json_tasklist = task:get_pending_tasks()
  for i = 1, #json_tasklist do
    local task_wibox = create_task_wibox(json_tasklist[i])
    local ntask = create_task_nav(task_wibox, json_tasklist[i], i)

    nav_tasklist:append(ntask)
    if i > MAX_TASKS_SHOWN then
      overflow_bottom[#overflow_bottom+1] = task_wibox
    else
      tasklist:add(task_wibox)
    end
  end

  -- Scrollbar UI
  if #json_tasklist > MAX_TASKS_SHOWN then
    update_scrollbar(#json_tasklist)
  else
    scrollbar_cont.visible = false
  end

  update_wibox_index()
end)

-- Determine which new tasks to show when scrolling
task:connect_signal("selected::task", function()
  if total_overflow() == 0 then return end

  local last_position_index = first_position_index + MAX_TASKS_SHOWN - 1
  local index     = task:focused_task_index()
  local old_index = task:old_focused_task_index()
  local gap = math.abs(index - old_index)

  if index == 1 and gap > 1 then
    if first_position_index == 1 then return end
    jump_top()
  elseif index == #task:get_pending_tasks() and gap > 1 then
    if first_position_index == #task:get_pending_tasks() then return end
    jump_end()
  elseif index < first_position_index then
    scroll_up()
  elseif index > last_position_index then
    scroll_down()
  end
end)

--- Add a single task to the task list
-- Note: this is called *after* task has been added to data table,
-- so #get_pending_tasks is the correct index
task:connect_signal("tasklist::add", function(_, new_task)
  local task_wibox = create_task_wibox(new_task)
  local index = #task:get_pending_tasks()
  local ntask = create_task_nav(task_wibox, new_task, index)
  nav_tasklist:append(ntask)
  tasklist:add(task_wibox)
  update_wibox_index()
  nav_tasklist:set_curr_item(index)
end)

--- Remove a task from the task list and task keynav hierarchy
-- Note: this is called *after* task has been removed from data table
task:connect_signal("tasklist::remove", function()
  local index_to_remove = task:focused_task_index()
  tasklist:remove(index_to_remove)
  nav_tasklist:remove_index(index_to_remove)
  update_wibox_index()

  if #nav_tasklist.items == 0 then return end

  -- Cursor will stay in the same position post removal
  -- Unless there are no more tasks
  -- (Unless you're removing the last one in the list, or there are no more tasks)
  local new_nav_index = index_to_remove
  local last_task_index = #task:get_pending_tasks()
  if index_to_remove == last_task_index + 1 then
    new_nav_index = new_nav_index - 1
  end

  -- The self.index field is used to set task.focused_task_index
  -- whenever a new task navitem is selected
  -- Must update these indices when you alter the order
  for i = new_nav_index, #nav_tasklist.items do
    nav_tasklist.items[i].index = i
  end

  nav_tasklist:set_curr_item(new_nav_index)
end)

task:connect_signal("tasklist::update_task_name", function(_, index, new_desc)
  local modtask = tasklist.children[1].children[index]
  local desc_wibox = modtask:get_children_by_id("description")[1]
  new_desc = new_desc:gsub("%^l", string.upper)
  desc_wibox:set_markup_silently(colorize(new_desc, beautiful.fg))
end)

task:connect_signal("tasklist::update_task_due", function(_, index, due)
  local modtask = tasklist.children[1].children[index]
  local due_wibox = modtask:get_children_by_id("due")[1]
  local due_text, due_color = format_due_date(due)
  due_wibox:set_markup_silently(colorize(due_text, due_color))
end)

--- Toggle start/stop: change text color between white (stopped) and green (started)
task:connect_signal("tasklist::update_start", function(_, index, desc, is_started)
  local modtask = tasklist.children[1].children[index]
  local desc_wibox = modtask:get_children_by_id("description")[1]
  local markup
  if is_started then
    markup = colorize(desc, beautiful.fg)
  else
    markup = colorize(desc, beautiful.green)
  end
  desc_wibox:set_markup_silently(markup)
end)

return function()
  return tasklist_widget, nav_tasklist
end
