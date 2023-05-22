
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █▄▄ █▀█ █▀▄ █▄█ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █▄█ █▄▀ ░█░ 

-- Displays a list of tasks for the currently-selected
-- tag and project.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gtable = require("gears.table")
local singlesel = require("frontend.widget.single-select")
local strutil = require("utils.string")
local task  = require("backend.system.task")

local tasklist = {}

--- @function gen_taskitem
-- @brief Generate a single tasklist entry.
local function gen_taskitem(t)
  local desc = ui.textbox({
    text = t.description
  })

  local due_text, overdue, color
  if t.due then
    due_text, overdue = strutil.iso_to_relative(t.due)
    color = overdue and beautiful.red[400] or beautiful.fg
  else
    due_text = "no due date"
    color = beautiful.fg
  end

  local due = ui.textbox({
    text = due_text,
    color = color
  })

  local taskitem = wibox.widget({
    desc,
    nil,
    due,
    layout = wibox.layout.align.horizontal,
  })

  taskitem:connect_signal("mouse::enter", function()
    desc:update_color(beautiful.red[400])
  end)

  taskitem:connect_signal("mouse::leave", function(self)
    self:update()
  end)

  function taskitem:update()
    local c = self.selected and beautiful.primary[400] or beautiful.fg
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

-- gtable.crush(tasklist, singlesel, true)
-- rawset(tasklist, "new", nil)
-- rawset(tasklist, "mt", nil)
-- 
-- function tasklist:add_item(t)
--   self:add(gen_taskitem(t))
-- end


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

task:connect_signal("ready::tasks", function(_, tag, project, tasks)
  tasklist:clear_elements()
  tasklist.tag = tag
  tasklist.project = project
  for i = 1, #tasks do
    local taskitem = gen_taskitem(tasks[i])
    tasklist:add_element(taskitem)
  end
end)

return function() return tasklist end
