
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local area = require("modules.keynav.area")
local navtask = require("modules.keynav.navitem").Task
local overviewbox = require("modules.keynav.navitem").OverviewBox
local math = math
local helpers = require("helpers")
local colorize = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date

local max_tasklist_height = dpi(580)
local first_visible_task_index = 1

local scrollbar

return function(task_obj)
  -- idk where to put this
  task_obj.max_tasks_shown = 21

  local function num_tasks()
    local project = task_obj.current_project
    return #task_obj.projects[project].tasks
  end

  -- Keyboard navigation
  -- Setting up custom keys is... a little clunky
  -- Need to update keynav to make this better
  local nav_tasklist
  local keys = require("ui.dash.tasks.keygrabber")(task_obj)
  nav_tasklist = area:new({
    name = "tasklist",
    circular = true,
  })

  keys["h"] = function()
    local navigator = nav_tasklist.nav
    navigator:set_area("projects")
  end
  nav_tasklist.keys = keys

  -- Define core UI components
  local tasklist_wrapper = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  })

  local tasklist = wibox.widget({
    spacing = dpi(8),
    layout = wibox.layout.flex.vertical,
  })

  local overflow_top = {}
  local overflow_bottom = {}

  local function total_overflow()
    return #overflow_top + #overflow_bottom
  end

  -- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
  -- ░█░ █▀█ ▄█ █░█ ▄█ 
  -- Returns tasks associated with a given project.
  local function create_task(name, due_date, start, id)
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

    local task = wibox.widget({
      taskname,
      nil,
      due,
      forced_height = dpi(20),
      layout = wibox.layout.align.horizontal,
    })

    return task
  end

  -- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀ █░█ █▀▄▀█ █▀▄▀█ ▄▀█ █▀█ █▄█ 
  -- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    ▄█ █▄█ █░▀░█ █░▀░█ █▀█ █▀▄ ░█░ 
  -- Create a summary listing all tasks as well as completion percentage
  local function create_tasklist(tag, project)
    local accent = beautiful.random_accent_color()

    if project == "(none)" or project == "noproj" then
      project = "No project"
    end

    local name_text = project:gsub("^%l", string.upper) -- capitalize 1st letter
    local name = wibox.widget({
      markup = colorize(name_text, accent),
      font = beautiful.alt_font .. "25",
      halign = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local project_tag = textbox({
      text = string.upper(tag),
      color = beautiful.fg,
      font = beautiful.font,
      size = 10,
      halign = "left",
    })

    local percent_completion = wibox.widget({
      markup = colorize("0%", beautiful.fg),
      font = beautiful.alt_font .. "Light 25",
      halign = "right",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local progress_bar = wibox.widget({
      color = accent,
      background_color = beautiful.bg_l3,
      value = 92,
      max_value = 100,
      border_width = dpi(0),
      forced_width = dpi(280),
      forced_height = dpi(5),
      widget = wibox.widget.progressbar,
    })

    -- Add tasks to task list
    nav_tasklist:remove_all_items()
    nav_tasklist:reset()
    tasklist:reset()
    local current_task_set = false
    overflow_top = {}
    overflow_bottom = {}
    local json_tasklist = task_obj.projects[project].tasks
    for i = 1, #json_tasklist do
      local desc  = json_tasklist[i]["description"]
      local due   = json_tasklist[i]["due"] or ""
      local id    = json_tasklist[i]["id"]
      local start = json_tasklist[i]["start"]
      local task = create_task(desc, due, start, id)

      nav_tasklist:append(navtask:new(task, task_obj, id))
      if #tasklist.children < task_obj.max_tasks_shown then
        tasklist:add(task)
      else
        table.insert(overflow_bottom, task)
      end

      if not current_task_set then
        current_task_set = true
        task_obj.current_task = json_tasklist[i]
      end
    end

    local max_tasks_shown = task_obj.max_tasks_shown
    local scrollbar_height = ((max_tasks_shown / #json_tasklist) * max_tasklist_height) or 0
    local maximum = (total_overflow() > 1 and total_overflow()) or 1
    scrollbar = wibox.widget({
      {
        id            = "bar",
        value         = 0,
        maximum       = maximum,
        forced_height = dpi(5),
        handle_width  = dpi(scrollbar_height),
        bar_color     = beautiful.task_scrollbar_bg,
        handle_color  = beautiful.task_scrollbar_fg,
        bar_shape     = gears.shape.rounded_rect,
        widget        = wibox.widget.slider,
      },
      direction = "west",
      widget    = wibox.container.rotate,
    })

    -- Calculate completion percentage
    local pending = #json_tasklist
    local total = task_obj.projects[project].total
    local completed = total - pending
    local percent = math.floor((completed / total) * 100) or 0

    -- Update bar with completion percentage
    progress_bar.value = percent
    local markup = colorize(percent.."%", beautiful.fg)
    percent_completion:set_markup_silently(markup)

    -- Update completion percentage
    local rem = pending.."/"..total.." REMAINING"
    local text = string.upper(tag).." - "..rem
    markup = colorize(text, beautiful.fg)
    project_tag:set_markup_silently(markup)

    local tasklist_header = wibox.widget({
      {
        {
          name,
          project_tag,
          layout = wibox.layout.fixed.vertical
        },
        nil,
        percent_completion,
        layout = wibox.layout.align.horizontal,
      },
      progress_bar,
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical
    })

    local scrollbar_cont = wibox.widget({
      scrollbar,
      right = dpi(15),
      visible = total_overflow() > 0,
      widget = wibox.container.margin,
    })

    -- Assemble final widget
    local widget = wibox.widget({
      {
        {
          tasklist_header,
          helpers.ui.vertical_pad(dpi(15)),
          {
            {
              scrollbar_cont,
              tasklist,
              layout = wibox.layout.align.horizontal,
            },
            height = max_tasklist_height,
            widget = wibox.container.constraint,
          },
          layout = wibox.layout.fixed.vertical,
        },
        top = dpi(15),
        bottom = dpi(20),
        left = dpi(25),
        right = dpi(25),
        widget = wibox.container.margin,
      },
      forced_width = dpi(600),
      bg = beautiful.dash_widget_bg,
      shape = gears.shape.rounded_rect,
      widget = wibox.container.background,
    })

    tasklist_wrapper:reset()
    tasklist_wrapper:add(widget)
    nav_tasklist.widget = overviewbox:new(widget, task_obj)

    if task_obj.switch_index then
      task_obj:emit_signal("tasks::switch_to_task_index", task_obj.index_to_switch)
      task_obj.switch_index = false
    end
  end -- end create proj summary


  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  task_obj:connect_signal("tasks::draw_first_overview", function(_, project)
    local tag = task_obj.current_tag
    create_tasklist(tag, project)
  end)

  -- █▀ █▀▀ █▀█ █▀█ █░░ █░░ █ █▄░█ █▀▀ 
  -- ▄█ █▄▄ █▀▄ █▄█ █▄▄ █▄▄ █ █░▀█ █▄█ 
  local function scroll_up()
    local bar = scrollbar.children[1]
    bar.value = bar.value - 1
    first_visible_task_index = first_visible_task_index - 1

    -- For scroll up, the last task gets hidden
    -- Prepend to overflow_bottom buffer
    local last_task_shown
    if #tasklist.children > (first_visible_task_index + 20) then
      last_task_shown = first_visible_task_index + task_obj.max_tasks_shown - 1
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
    first_visible_task_index = first_visible_task_index + 1

    -- When scrolling down, the 1st visible task gets hidden
    -- Append to overflow_top buffer
    table.insert(overflow_top, tasklist.children[1])
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
    nav_tasklist:set_curr_item(num_tasks() - #overflow_bottom)

    while #overflow_bottom > 0 do
      scroll_down()
    end
    nav_tasklist:set_curr_item(num_tasks())
  end

  -- Emitted by keygrabber when navigating to the previous or next task
  -- Determines which items to show when scrolling and also sets current
  -- task index
  task_obj:connect_signal("tasks::task_selected", function(_)
    local old_index = task_obj.current_task_index or 1
    task_obj.current_task_index = nav_tasklist.index

    -- Everything below here is relevant to scrolling only
    if total_overflow() == 0 then return end

    local max_tasks_shown = task_obj.max_tasks_shown
    local index = nav_tasklist.index
    local last_visible_task_index = first_visible_task_index + max_tasks_shown - 1
    local gap = math.abs(old_index - index)

    if index == 1 and gap > 1 then
      if first_visible_task_index == 1 then return end
      jump_top()
    elseif index == num_tasks() and gap > 1 then
      if first_visible_task_index == num_tasks() then return end
      jump_end()
    elseif index < first_visible_task_index then
      scroll_up()
    elseif index > last_visible_task_index then
      scroll_down()
    end
  end)

  -- json_parsed signal tells us that the data is ready to be
  -- processed
  task_obj:connect_signal("tasks::project_selected", function()
    local tag     = task_obj.current_tag
    local project = task_obj.current_project
    create_tasklist(tag, project)
  end)

  return tasklist_wrapper, nav_tasklist
end
