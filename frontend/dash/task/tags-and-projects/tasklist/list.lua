
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █▄▄ █▀█ █▀▄ █▄█
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █▄█ █▄▀ ░█░

-- Displays a list of tasks for the currently selected tag and project.
-- Abandon all hope ye who enter here.

local ui = require("utils.ui")
local dpi = ui.dpi
local task = require("backend.system.task")
local wibox = require("wibox")
local keynav = require("modules.keynav")
local beautiful = require("beautiful")
local gen_taskitem = require("frontend.dash.task.gen_taskitem")

local MAX_VISIBLE_ELEMENTS = 19
local first_visible_index  = 1
local last_visible_index   = MAX_VISIBLE_ELEMENTS
local previous_index  = 0
local overflow_top    = {}
local overflow_bottom = {}
local scroll_up, scroll_down, jump_top, jump_end

local scrollbar

-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █░█ █ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █ 

-- The main layout where the tasks will be inserted.
local tasklist = wibox.widget({
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
  ---
  area = keynav.area({
    name = "nav_tasklist",
    keys = require("frontend.dash.task.tags-and-projects.tasklist.keybinds"),
  })
})

function tasklist:update()
  if #overflow_top + #overflow_bottom == 0 then return end

  last_visible_index = first_visible_index + MAX_VISIBLE_ELEMENTS - 1
  local index = tasklist.area.active_element.index
  local num_elements = #self.children + #overflow_top + #overflow_bottom

  -- Distance between currently selected element and the previously selected element
  local gap = math.abs(index - previous_index)

  if index == 1 and gap > 1 then
    if first_visible_index == 1 then return end
    jump_top()
  elseif index == num_elements and gap > 1 then
    if first_visible_index == num_elements then return end
    jump_end()
  elseif index < first_visible_index and gap == 1 then
    scroll_up()
  elseif index > last_visible_index and gap == 1 then
    scroll_down()
  end

  previous_index = index
end

--- @method set_position
function tasklist:set_position(idx)
  while first_visible_index < idx do
    scroll_down()
  end

  -- TODO: This is messy af
  local c = tasklist.area.active_element.desc._color
  tasklist.area.active_element.desc:update_color(c)
  tasklist.area.active_element.indicator.bg = c

  previous_index = idx
end

-- █▀ █▀▀ █▀█ █▀█ █░░ █░░ █▄▄ ▄▀█ █▀█
-- ▄█ █▄▄ █▀▄ █▄█ █▄▄ █▄▄ █▄█ █▀█ █▀▄

local bar = wibox.widget({
  id                  = "bar",
  value               = 0,
  forced_height       = ui.dpi(5), -- since it's rotated, this is width
  bar_color           = beautiful.neutral[700],
  handle_color        = beautiful.primary[600],
  handle_border_width = 0,
  shape               = ui.rrect(),
  bar_shape           = ui.rrect(),
  widget              = wibox.widget.slider,
})

scrollbar = wibox.widget({
  {
    bar,
    direction = "west",
    widget    = wibox.container.rotate,
  },
  right = ui.dpi(15),
  widget = wibox.container.margin,
  visible = false
})

local function scroll_total_overflow()
  return #overflow_top + #overflow_bottom
end

local function update_scrollbar()
  if #overflow_top + #overflow_bottom == 0 then
    scrollbar.visible = false
    return
  end

  local num_elements = #tasklist.children + scroll_total_overflow()
  bar.handle_width = ((MAX_VISIBLE_ELEMENTS / num_elements) * ui.dpi(550))
  bar.maximum = (scroll_total_overflow() > 1 and scroll_total_overflow()) or 1
  scrollbar.visible = true
end

function scroll_up()
  first_visible_index = first_visible_index - 1
  bar.value = bar.value - 1

  -- NOTE: This was in the old code, no idea what the fuck it's doing but it doesn't work without it
  if #tasklist.children > (first_visible_index + MAX_VISIBLE_ELEMENTS) then
    last_visible_index = first_visible_index + MAX_VISIBLE_ELEMENTS + 1
  else
    last_visible_index = #tasklist.children
  end

  -- When scrolling up, the last visible element gets prepended to overflow_bottom
  table.insert(overflow_bottom, 1, tasklist.children[last_visible_index])
  tasklist:remove(#tasklist.children)

  -- Prepend last task from overflow_top to layout
  tasklist:insert(1, overflow_top[#overflow_top])
  table.remove(overflow_top, #overflow_top)
end

function scroll_down()
  first_visible_index = first_visible_index + 1
  bar.value = bar.value + 1

  -- When scrolling down, the first visible element gets appended to overflow_bottom
  overflow_top[#overflow_top+1] = tasklist.children[1]
  tasklist:remove(1)

  -- Append the first element from overflow_bottom to layout
  tasklist:add(overflow_bottom[1])
  table.remove(overflow_bottom, 1)
end

function jump_top()
  while #overflow_top > 0 do
    scroll_up()
  end
  tasklist.area:set_active_element_by_index(1)
end

function jump_end()
  while #overflow_bottom > 0 do
    scroll_down()
  end
  tasklist.area:set_active_element_by_index(#tasklist.children + #overflow_top)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░

tasklist.area:connect_signal("area::left", function()
  local c = tasklist.area.active_element.desc._color
  tasklist.area.active_element.desc:update_color(c)
  tasklist.area.active_element.indicator.bg = c
end)

task:connect_signal("ready::tasks", function(_, tag, project, tasks)
  tasklist:reset()
  tasklist.area:clear()
  overflow_top = {}
  overflow_bottom = {}
  previous_index = 0
  first_visible_index = 1

  -- local restore_idx = 1

  for i = 1, #tasks do
    local taskitem = gen_taskitem(tasks[i], i)

    if #tasklist.children < MAX_VISIBLE_ELEMENTS then
      tasklist:add(taskitem)
    else
      overflow_bottom[#overflow_bottom+1] = taskitem
    end

    -- NOTE: For restoring we should keep track of the fvti as well
    -- if task.restore and task.restore.id == tasks[i].id then
    --   restore_idx = i
    -- end

    tasklist.area:append(taskitem)
  end

  update_scrollbar()

  -- Initialize the first active task
  -- tasklist:update()
  tasklist:set_position(1)
  tasklist.area:set_active_element_by_index(1)
end)

-- Update UI when scrolling
task:connect_signal("selected::task", function()
  tasklist:update()
end)

return function()
  return tasklist, scrollbar
end
