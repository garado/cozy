
-- █▀▀ █▀▀ █▄░█    ▀█▀ ▄▀█ █▀ █▄▀ █ ▀█▀ █▀▀ █▀▄▀█ 
-- █▄█ ██▄ █░▀█ ▄▄ ░█░ █▀█ ▄█ █░█ █ ░█░ ██▄ █░▀░█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gears = require("gears")
local strutil = require("utils.string")
local task = require("backend.system.task")

--- @function gen_taskitem
-- @brief Generate a single tasklist entry.
return function(t, index)
  -- Determine colors for task name, due date
  local text_color = beautiful.fg
  local due_color  = beautiful.neutral[300]

  local due_str, is_overdue
  if t.due then
    local ts = strutil.dt_convert(t.due, strutil.dt_format.iso, nil)
    due_str, is_overdue = strutil.ts_to_relative(ts)
  end

  if is_overdue or t.urgency > 7.5 then
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
    index = index,
  })

  taskitem:connect_signal("mouse::enter", function(self)
    self:emit_signal("button::press")
    task.active_task = self.data
    task.active_task_ui = desc
    task:emit_signal("selected::task", self.data)
  end)

  taskitem:connect_signal("mouse::leave", function(self)
    self:update()
  end)

  taskitem:connect_signal("button::press", function(self)
    self:update()
  end)

  function taskitem:update()
    local c = self.selected and beautiful.primary[400] or desc._color
    indicator.bg = self.selected and beautiful.fg or beautiful.neutral[800]
    desc:update_color(c)
  end

  return taskitem
end
