
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █░░ █ █▀ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄▄ █ ▄█ ░█░ 
-- Create a list of projects and show completion percentage.

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
      navigator:set_area("overview")
    end,
  }
})

return function(task_obj)
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
    print("list: connect tag_json_parsed")
    draw_project_list()
  end)

  task_obj:connect_signal("tasks::project_json_parsed", function()
    print("list: connect project_json_parsed")
    draw_project_list()
  end)

  -- Prevent flicker by only drawing when all ui-related async calls have
  -- finished
  task_obj:connect_signal("tasks::project_async_done", function(_, widget, name)
    -- When adding the first project to the project list, clear all old projects
    if no_projects_added then
      no_projects_added = false
      project_list:reset()
    end

    if name == task_obj.current_project then
      print("projectlist: emit draw_first_overview")
      task_obj:emit_signal("tasks::draw_first_overview", name)
    end

    if not task_obj.current_project then
      print("projectlist: emit draw_first_overview")
      task_obj.current_project = name
      task_obj:emit_signal("tasks::draw_first_overview", name)
    end

    project_list:add(widget)

    -- Keyboard navigation
    local nav_project = tasks_textbox:new(widget)
    function nav_project:release()
      task_obj.current_project = name
      print("listbutton: emit project_selected")
      task_obj:emit_signal("tasks::project_selected")
    end
    nav_projects:append(nav_project)
  end)

  return projects_widget, nav_projects
end
