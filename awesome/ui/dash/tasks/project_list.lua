
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █░░ █ █▀ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄▄ █ ▄█ ░█░ 

-- Create a list of projects and show completion percentages.
-- This is done every time a new tag is selected.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local colorize = require("helpers.ui").colorize_text
local area = require("modules.keynav.area")
local tasks_textbox = require("modules.keynav.navitem").Tasks_Textbox
local taskbox = require("modules.keynav.navitem").Taskbox
local math = math

-- Keyboard navigation
local nav_projects
nav_projects = area:new({
  name = "projects",
  keys = {
    ["l"] = function()
      local navigator = nav_projects.nav
      navigator:set_area("tasklist")
    end,
  },
  hl_persist_on_area_switch = true,
})

return function(task_obj)
  local total_projects_in_tag = 0

  local function count_projects_in_tag()
    total_projects_in_tag = 0
    for _, _ in pairs(task_obj.projects) do
      total_projects_in_tag = total_projects_in_tag + 1
    end
  end

  local function create_project_button(project)
    local tag = task_obj.current_tag

    -- Handle tasks that don't have an associated project
    if project == "(none)" or project == "noproj" then
      project = "No project"
    end

    -- Update progress bar/completion percentage
    local unset_context = "task context none ; "
    local filters = "task tag:'"..tag.."' project:'"..project.."' "
    local status = " '(status:pending or status:completed)' "
    local cmd = unset_context .. filters .. status .. "count"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local pending = #task_obj.projects[project].tasks
      local total = tonumber(stdout) or 0
      local completed = total - pending
      local percent = math.floor((completed / total) * 100) or 0

      local text = project.." ("..percent .. "%)"
      local markup = colorize(text, beautiful.fg)
      local textbox = wibox.widget({
        markup = markup,
        align = "center",
        forced_height = dpi(20),
        font = beautiful.font_name .. "11",
        widget = wibox.widget.textbox,
      })

      -- Prevent flicker by only drawing when all ui-related async calls have
      -- finished
      task_obj.projects[project].total = total
      task_obj:emit_signal("tasks::project_async_done", textbox, project)
    end)
  end -- end create_project_button

  local project_list = wibox.widget({
    spacing = dpi(5),
    layout = wibox.layout.flex.vertical,
  })

  local project_list_buffer = wibox.widget({
    spacing = dpi(5),
    layout = wibox.layout.flex.vertical,
  })

  local projects_widget = wibox.widget({
    {
      {
        {
          helpers.ui.create_dash_widget_header("Projects"),
          project_list,
          spacing = dpi(10),
          --forced_width = dpi(150),
          fill_space = true,
          layout = wibox.layout.fixed.vertical,
        },
        top = dpi(15),
        bottom = dpi(20),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place
    },
    forced_width = dpi(290),
    bg = beautiful.dash_widget_bg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })
  nav_projects.widget = taskbox:new(projects_widget)

  local no_projects_added = true
  local function draw_project_list()
    nav_projects:remove_all_items()
    nav_projects:reset()
    no_projects_added = true

    for project, _ in pairs(task_obj.projects) do
      create_project_button(project)
    end
  end

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  -- json_parsed signal tells us that the data is ready to be
  -- processed
  -- need to rename and reuse this signal cause project_json_parsed is the exact same
  task_obj:connect_signal("tasks::tag_json_parsed", function()
    count_projects_in_tag()
    draw_project_list()
  end)

  task_obj:connect_signal("tasks::project_json_parsed", function()
    count_projects_in_tag()
    draw_project_list()
  end)

  task_obj:connect_signal("tasks::reload_project_list_all", function()
    count_projects_in_tag()
    draw_project_list()
  end)

  -- Prevent flicker by only drawing when all ui-related async calls have
  -- finished.
  -- (Reminder: the async calls are for calculating the percentage
  -- completion per project in the project list)
  local async_calls_completed = 0
  task_obj:connect_signal("tasks::project_async_done", function(_, widget, name)
    -- When adding the first project to the project list, clear all old projects
    if no_projects_added then
      async_calls_completed = 0
      no_projects_added = false
      project_list_buffer:reset()
    end

    -- If the current project is nil, then no project is selected.
    -- This happens when you select a new tag.
    -- Set the current project to this async call's project so that
    -- an overview can be drawn.
    if not task_obj.current_project then
      task_obj.current_project = name
      task_obj:emit_signal("tasks::project_selected", name)
    end

    -- If the async call is associated with the current project, then
    -- draw the project overview
    if name == task_obj.current_project then
      task_obj:emit_signal("tasks::project_selected", name)
    end

    project_list_buffer:add(widget)

    -- Keyboard navigation
    local nav_project = tasks_textbox:new(widget)
    function nav_project:release()
      task_obj.current_project = name
      print("listbutton: emit project_selected")
      task_obj:emit_signal("tasks::project_selected")
    end
    nav_projects:append(nav_project)

    async_calls_completed = async_calls_completed + 1
    if async_calls_completed == total_projects_in_tag then
      project_list:reset()
      for i = 1, #project_list_buffer.children do
        project_list:add(project_list_buffer.children[i])
      end
    end
  end)

  return projects_widget, nav_projects
end
