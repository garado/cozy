
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local area = require("modules.keynav.area")
local navtask = require("modules.keynav.navitem").Task
local overviewbox = require("modules.keynav.navitem").OverviewBox
local colorize = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date

local task = require("core.system.task")

-- █▄▀ █▀▀ █▄█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄  
-- █░█ ██▄ ░█░ █▄█ █▄█ █▀█ █▀▄ █▄▀  

-- Setting up custom keys is... a little clunky
-- Need to update keynav to make this better
local nav_tasklist
nav_tasklist = area:new({
  name = "tasklist",
  circular = true,
  keys = require("ui.dash.task.keys.tasklist")
})

-- █░█ █
-- █▄█ █

local tasklist_wrapper = wibox.widget({
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
})

local tasklist = wibox.widget({
  spacing = dpi(8),
  layout = wibox.layout.flex.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

local function create_task_wibox(name, due_date, start, id)
  name = name:gsub("%^l", string.upper)
  local taskname_color = start and beautiful.green or beautiful.fg
  local taskname = wibox.widget({
    markup = colorize(name, taskname_color),
    font = beautiful.font_name .. "12",
    ellipsize = "end",
    widget = wibox.widget.textbox,
  })

  local due_text, due_color = format_due_date(due_date)
  local due = wibox.widget({
    markup = colorize(due_text, due_color or beautiful.fg_sub),
    font = beautiful.font_name .. "12",
    halign = "right",
    align = "center",
    widget = wibox.widget.textbox,
  })

  local task_wibox = wibox.widget({
    taskname,
    nil,
    due,
    forced_height = dpi(20),
    layout = wibox.layout.align.horizontal,
  })

  return task_wibox
end

local function update_tasklist()
  -- Add tasks to task list
  nav_tasklist:remove_all_items()
  nav_tasklist:reset()
  tasklist:reset()
  local current_task_set = false -- forgot why this is needed?
  -- overflow_top = {}
  -- overflow_bottom = {}
  local json_tasklist = task:get_pending_tasks()
  for i = 1, #json_tasklist do
    local desc  = json_tasklist[i]["description"]
    local due   = json_tasklist[i]["due"] or ""
    local id    = json_tasklist[i]["id"]
    local start = json_tasklist[i]["start"]

    local task_wibox = create_task_wibox(desc, due, start, id)

    -- Keyboard navigation setup
    local ntask = navtask:new(task_wibox, nil, id)
    function ntask:select_on()
      self.selected = true
      local text = self.widget.children[1]
      text.font = beautiful.font_name .. "Bold 12"
      task:set_focused_task(json_tasklist[i], i)
    end

    function ntask:select_off()
      self.selected = false
      local text = self.widget.children[1]
      text.font = beautiful.font_name .. "12"
    end

    nav_tasklist:append(ntask)
    tasklist:add(task_wibox)

    -- if #tasklist.children < task_obj.max_tasks_shown then
    --   tasklist:add(task)
    -- else
    --   table.insert(overflow_bottom, task)
    -- end

    if not current_task_set then
      current_task_set = true
    end
  end -- end for

  -- Handles switching to the correct index after redrawing because a task
  -- was added/deleted/completed
  if task.need_switch_index then
    task:emit_signal("ui::switch_tasklist_index", task.switch_index)
    task.need_switch_index = false
  end
end

task:connect_signal("update::tasks", function(_, tag, project)
  update_tasklist()
end)

return function()
  return tasklist, nav_tasklist
end
