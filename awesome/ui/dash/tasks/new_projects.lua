
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

-- Create a fancy-looking list of projects.

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

return function(task_obj)
  local function create_project_button(tag, project, tasks)
    -- Handle tasks that don't have an associated project
    if project == "(none)" or project == "noproj" then
      project = "No project"
    end

    -- Update progress bar/completion percentage
    local cmd = "task context none ; task tag:"..tag.." project:'"..project.. "' count"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local pending = #tasks
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
      task_obj:emit_signal("tasks::projectlist_ready", textbox, project)
    end)
  end -- end create_project_button

  -- Keyboard navigation
  local nav_projects = area:new({
    name = "projects",
    circular = true,
  })

  local project_list = wibox.widget({
    spacing = dpi(5),
    layout = wibox.layout.flex.vertical,
  })

  -- json_parsed signal tells us that the data is ready to be
  -- processed
  local no_projects_added = true
  task_obj:connect_signal("tasks::json_parsed", function()
    nav_projects:remove_all_items()
    nav_projects:reset()
    no_projects_added = true

    local tag = task_obj.current_tag
    for project, tasks in pairs(task_obj.projects) do
      create_project_button(tag, project, tasks)
    end
  end)

  -- Prevent flicker by only drawing when all ui-related async calls have
  -- finished
  task_obj:connect_signal("tasks::projectlist_ready", function(_, widget, name)
    -- When adding the first project to the project list,
    -- clear all old projects, then move navigator to proj list
    if no_projects_added then
      no_projects_added = false
      project_list:reset()
    end

    project_list:add(widget)

    -- Keyboard navigation
    local nav_project = tasks_textbox:new(widget)
    function nav_project:release()
      task_obj.current_project = name
      task_obj:emit_signal("tasks::project_selected")
    end
    nav_projects:append(nav_project)
  end)

  local widget = wibox.widget({
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

  nav_projects.widget = taskbox:new(widget)
  return widget, nav_projects
end
