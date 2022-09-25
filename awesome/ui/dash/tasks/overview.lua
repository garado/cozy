
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 
-- Project overview consists of:
--    * project completion percentage
--    * list of tasks and their due dates
-- Also includes a keygrabber to enable modifying/adding/deleting tasks. :)

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local area = require("modules.keynav.area")
local navtask = require("modules.keynav.navitem").Task
local overviewbox = require("modules.keynav.navitem").OverviewBox
-- local animation = require("modules.animation")
local math = math
local helpers = require("helpers")
local colorize = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date

return function(task_obj)
  -- Keyboard navigation
  local keys = require("ui.dash.tasks.keygrabber")(task_obj)
  local nav_overview = area:new({
    name = "overview",
    circular = true,
    keys = keys,
  })

  -- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
  -- ░█░ █▀█ ▄█ █░█ ▄█ 
  -- Returns tasks associated with a given project.
  local function create_task(name, due_date)
    name = name:gsub("%^l", string.upper)
    local taskname = wibox.widget({
      markup = colorize(name, beautiful.fg),
      font = beautiful.font_name .. "12",
      ellipsize = "end",
      --forced_width = dpi(450),
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

    return wibox.widget({
      taskname,
      nil,
      due,
      layout = wibox.layout.align.horizontal,
    })
  end

  -- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀ █░█ █▀▄▀█ █▀▄▀█ ▄▀█ █▀█ █▄█ 
  -- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    ▄█ █▄█ █░▀░█ █░▀░█ █▀█ █▀▄ ░█░ 
  -- Create a summary listing all tasks as well as completion percentage
  local function create_project_summary(tag, project, tasks)
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
      --background_color = beautiful.cash_budgetbar_bg,
      value = 92,
      max_value = 100,
      border_width = dpi(0),
      forced_width = dpi(280),
      forced_height = dpi(5),
      widget = wibox.widget.progressbar,
    })

    local tasklist = wibox.widget({
      spacing = dpi(8),
      layout = wibox.layout.flex.vertical,
    })

    local desc = 1
    local due  = 2
    local id   = 3
    for i = 1, #tasks do
      local id_ = tasks[i][id]
      local task = create_task(tasks[i][desc], tasks[i][due])
      nav_overview:append(navtask:new(task, task_obj, id_))
      tasklist:add(task)
    end

    local widget = wibox.widget({
      {
        {
          {
            { -- header
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
          },
          helpers.ui.vertical_pad(dpi(15)),
          tasklist,
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

    -- update progress bar/completion percentage
    local cmd = "task context none ; task tag:"..tag.." project:'"..project.. "' count"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      print(cmd)
      print(stdout)
      local pending = #tasks
      local total = tonumber(stdout) or 0
      local completed = total - pending
      local percent = math.floor((completed / total) * 100) or 0

      progress_bar.value = percent
      --progress_bar.value = 0
      local markup = colorize(percent.."%", beautiful.fg)
      percent_completion:set_markup_silently(markup)

      -- tag
      local rem = pending.."/"..total.." REMAINING"
      local text = string.upper(tag).." - "..rem
      markup = colorize(text, beautiful.fg)
      project_tag:set_markup_silently(markup)

      -- fun animation!
      --local anim = animation:new({
      --  duration = 1.25,
      --  target = percent,
      --  easing = animation.easing.inOutExpo,
      --  update = function(_, pos)
      --    progress_bar.value = dpi(pos)
      --    markup = colorize(dpi(pos).."%", beautiful.fg)
      --    percent_completion:set_markup_silently(markup)
      --  end
      --})

      -- prevent flicker by only drawing when ready
      task_obj:emit_signal("tasks::overview_ready", widget)
      --anim:start()
    end)
  end -- end create proj summary

  local overview = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  })

  task_obj:connect_signal("tasks::json_parsed", function()
    -- ugh
    local project
    for k, _ in pairs(task_obj.projects) do
      project = k
      break
    end
    task_obj.current_project = project

    local tag     = task_obj.current_tag
    local tasks   = task_obj.projects[project]
    nav_overview:remove_all_items()
    nav_overview:reset()
    create_project_summary(tag, project, tasks)
  end)

  -- json_parsed signal tells us that the data is ready to be
  -- processed
  task_obj:connect_signal("tasks::project_selected", function()
    local tag     = task_obj.current_tag
    local project = task_obj.current_project
    local tasks   = task_obj.projects[project]
    nav_overview:remove_all_items()
    nav_overview:reset()
    create_project_summary(tag, project, tasks)
  end)

  -- prevent flicker by only drawing when ready
  task_obj:connect_signal("tasks::overview_ready", function(_, widget)
    overview:reset()
    overview:add(widget)
    nav_overview.widget = overviewbox:new(widget, task_obj)
  end)

  return overview, nav_overview
end
