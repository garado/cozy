
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

-- Create project summaries for all projects within a given tag.
-- Integrated with Taskwarrior.
-- A project summary includes:
  -- project name
  -- completion percentage
  -- list of tasks associated with project

-- How it works:
  -- this file returns a function
  -- init.lua calls this file/function with a tag and a wibox as its argument
  -- gets list of projects from output of `task tag:given_tag projects`
  -- calls create_project_summary() for each of those projects

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local helpers = require("helpers")

-- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
-- ░█░ █▀█ ▄█ █░█ ▄█ 
-- Returns tasks associated with a given project.
local function create_task(name, due_date)
  local taskname = textbox({
    text = name:gsub("%^l", string.upper),
    font = beautiful.alt_font,
    size = 15,
  })

  local due = textbox({
    text = due_date,
    font = beautiful.alt_font,
    size = 12,
    color = beautiful.fg_sub,
  })

  return wibox.widget({
    taskname,
    nil,
    due,
    layout = wibox.layout.align.horizontal,
  })
end

local function create_all_tasks(project)
  local cmd = ""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
  end)
end

-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀ █░█ █▀▄▀█ █▀▄▀█ ▄▀█ █▀█ █▄█ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    ▄█ █▄█ █░▀░█ █░▀░█ █▀█ █▀▄ ░█░ 
local function create_project_summary(project_name, tag)
  local tasks = wibox.widget({
    create_task("Prelab", "in 2 days"),
    create_task("Prelab", "in 2 days"),
    create_task("Prelab", "in 2 days"),
    create_task("Prelab", "in 2 days"),
    create_task("Prelab", "in 2 days"),
    create_task("Prelab", "in 2 days"),
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  })

  local accent = beautiful.random_accent_color()
  if project_name == "(none)" then project_name = "No project" end
  local name_text = project_name:gsub("^%l", string.upper) -- capitalize 1st letter
  local name = wibox.widget({
    markup = helpers.ui.colorize_text(name_text, accent),
    font = beautiful.alt_font_name .. "Light 25",
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
    markup = helpers.ui.colorize_text("92%", beautiful.fg),
    font = beautiful.alt_font .. "Light 25",
    halign = "right",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local progress_bar = wibox.widget({
    color = accent,
    background_color = beautiful.cash_budgetbar_bg,
    value = 92,
    max_value = 100,
    border_width = dpi(0),
    forced_width = dpi(280),
    forced_height = dpi(5),
    widget = wibox.widget.progressbar,
  })

  local project = wibox.widget({
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
        helpers.ui.vertical_pad(dpi(8)),
        tasks,
        layout = wibox.layout.fixed.vertical
      },
      top = dpi(5),
      bottom = dpi(18),
      left = dpi(25),
      right = dpi(25),
      widget = wibox.container.margin,
    },
    bg = beautiful.dash_widget_bg,
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  return project
end

-- █▀█ ▄▀█ █▀█ █▀ █▀▀ 
-- █▀▀ █▀█ █▀▄ ▄█ ██▄ 
-- Creates a list of projects given the output of `task tag:tagname projects`
local function parse_taskw_projects(stdout)
  local projects = {}
  for line in string.gmatch(stdout, "[^\r\n]+") do
    -- the task count is the string of numbers at end of line
    -- so to get the task count, remove everything except for that
    local count = string.gsub(line, "[^%d+$]", "")

    -- to get project name, remove the task count
    local name = string.gsub(line, "%s+%d+$", "")

    local project = {
      ["name"]  = name,
      ["count"] = count,
    }
    table.insert(projects, project)
  end

  -- remove non-project lines
  table.remove(projects, 1) -- header
  table.remove(projects, 1) -- header
  table.remove(projects) -- last line of output shows how many projects there are

  return projects
end

return function(tag, widget)
  local cmd = "task context none ; task tag:"..tag.." projects"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local projects = parse_taskw_projects(stdout)
    widget:reset()
    for i = 1, #projects do
      widget:add(create_project_summary(projects[i]["name"], tag))
    end
  end)
end
