
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Project overview consists of:
--    * project completion percentage
--    * list of tasks and their due dates
-- Also includes a keygrabber to enable modifying/adding/deleting tasks. :)

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

local max_tasks_shown = 21
local max_tasklist_height = dpi(580)
local first_visible_task_index = 1

local scrollbar

return function(task_obj)
  -- Keyboard navigation
  -- Setting up custom keys is... a little clunky
  -- Need to update keynav to make this better
  local nav_overview
  local keys = require("ui.dash.tasks.keygrabber")(task_obj)
  nav_overview = area:new({
    name = "overview",
    circular = true,
  })

  keys["h"] = function()
    local navigator = nav_overview.nav
    navigator:set_area("projects")
  end
  nav_overview.keys = keys

  -- Define core UI components
  local overview = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  })

  local tasklist = wibox.widget({
    spacing = dpi(8),
    layout = wibox.layout.flex.vertical,
  })

  local tasklist_overflow = {}

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
  local function create_project_summary(tag, project)
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
    nav_overview:remove_all_items()
    nav_overview:reset()
    tasklist:reset()
    local current_task_set = false
    tasklist_overflow = {}
    local json_tasklist = task_obj.projects[project].tasks
    for i = 1, #json_tasklist do
      local desc  = json_tasklist[i]["description"]
      local due   = json_tasklist[i]["due"] or ""
      local id    = json_tasklist[i]["id"]
      local start = json_tasklist[i]["start"]
      local task = create_task(desc, due, start, id)

      --print(id .. ": " .. desc)
      nav_overview:append(navtask:new(task, task_obj, id))
      if #tasklist.children < max_tasks_shown then
        tasklist:add(task)
      else
        table.insert(tasklist_overflow, task)
        --local tmp = navtask:new(task, task_obj, id)
        --table.insert(navtasklist_overflow, tmp)
      end

      if not current_task_set then
        current_task_set = true
        task_obj.current_task = json_tasklist[i]
      end
    end

    local scrollbar_height = (max_tasks_shown / #json_tasklist) * max_tasklist_height
    scrollbar = wibox.widget({
      {
        id = "bar",
        value = 0,
        maximum = #tasklist_overflow - 1,
        forced_height = dpi(5),
        handle_width = dpi(scrollbar_height),
        bar_color = beautiful.task_scrollbar_bg,
        handle_color = beautiful.task_scrollbar_fg,
        bar_shape = gears.shape.rounded_rect,
        widget = wibox.widget.slider,
      },
      direction = "west",
      widget = wibox.container.rotate,
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

    local overview_header = wibox.widget({
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
      visible = #tasklist_overflow > 0,
      widget = wibox.container.margin,
    })

    -- Assemble final widget
    local widget = wibox.widget({
      {
        {
          overview_header,
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

    overview:reset()
    overview:add(widget)
    nav_overview.widget = overviewbox:new(widget, task_obj)

    if task_obj.switch_index then
      print("overview: proj summary created; switch index flag is set. index "..task_obj.index_to_switch)
      task_obj:emit_signal("tasks::switch_to_task_index", task_obj.index_to_switch)
      task_obj.switch_index = false
    end
  end -- end create proj summary


  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  task_obj:connect_signal("tasks::draw_first_overview", function(_, project)
    print("overview: connect draw_first_overview")
    local tag = task_obj.current_tag
    create_project_summary(tag, project)
  end)

  -- Emitted by keygrabber when navigating to the previous or next task
  -- Determines which items to show when scrolling
  task_obj:connect_signal("tasks::task_selected", function(_)
    if #tasklist_overflow == 0 then return end

    print("task selected: fvti is "..first_visible_task_index)
    --scrollbar.children[1].value = nav_overview.index - 1
    --print("index " ..nav_overview.index)
    local index = nav_overview.index - 1
    local limit = first_visible_task_index + max_tasks_shown - 1
    local bar = scrollbar.children[1]

    -- Scroll up when the new index is less than the index of the first task 
    -- currently shown
    if index < first_visible_task_index then
      print("scroll up")
      first_visible_task_index = first_visible_task_index - 1
      bar.value = bar.value - 1

      -- For scroll up, the last task gets hidden
      -- Add it to beginning of task overflow buffer
      table.insert(tasklist_overflow, tasklist.children[#tasklist.children])
      tasklist:remove(#tasklist.children)

      -- Add the last task from overflow buffer
      tasklist:add(tasklist_overflow[#tasklist_overflow])
      table.remove(tasklist_overflow, #tasklist_overflow)
    -- Scroll down to next task if index exceeds limit
    elseif limit < nav_overview.index - 1 then
      first_visible_task_index = first_visible_task_index + 1
      bar.value = bar.value + 1

      -- For scroll down, the 1st task gets hidden
      -- Add it to end of task overflow buffer
      table.insert(tasklist_overflow, tasklist.children[1])
      tasklist:remove(1)

      -- Add the first task from overflow buffer
      tasklist:add(tasklist_overflow[1])
      table.remove(tasklist_overflow, 1)

      tasklist:emit_signal("widget::redraw_needed")
    end
  end)

  -- json_parsed signal tells us that the data is ready to be
  -- processed
  task_obj:connect_signal("tasks::project_selected", function()
    print("overview: connect project_selected")
    local tag     = task_obj.current_tag
    local project = task_obj.current_project
    create_project_summary(tag, project)
  end)

  return overview, nav_overview
end

