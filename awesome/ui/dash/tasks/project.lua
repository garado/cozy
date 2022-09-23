
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
local ui = require("helpers.ui")
local json = require("modules.json")

local function format_due_date(due)
  if not due or due == "" then return "no due date" end

  -- taskwarrior returns due date as string
  -- convert that to a lua timestamp
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = due:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })

  -- turn timestamp into human-readable format
  local now = os.time()
  local time_difference = ts - now
  local abs_time_difference = math.abs(time_difference)
  local days_rem = math.floor(abs_time_difference / 86400)
  local hours_rem = math.floor(abs_time_difference / 3600)

  -- due date formatting
  local due_date_text
  if days_rem >= 1 then -- in x days / x days ago
    due_date_text = days_rem .. " day"
    if days_rem > 1 then
      due_date_text = due_date_text .. "s"
    end
  else -- in x hours / in <1 hour / etc
    if hours_rem == 1 then
      due_date_text = hours_rem .. " hour"
    elseif hours_rem < 1 then
      due_date_text = "&lt;1 hour"
    else
      due_date_text = hours_rem .. " hours"
    end
  end

  if time_difference < 0 then -- overdue
    due_date_text = due_date_text .. " ago"
  else
    due_date_text = "in " .. due_date_text
  end

  return due_date_text
end

-- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
-- ░█░ █▀█ ▄█ █░█ ▄█ 
-- Returns tasks associated with a given project.
local function create_task(name, due_date)
  name = name:gsub("%^l", string.upper)
  local taskname = wibox.widget({
    markup = ui.colorize_text(name, beautiful.fg),
    font = beautiful.font_name .. "11",
    ellipsize = "end",
    forced_width = dpi(310),
    widget = wibox.widget.textbox,
  })

  local due = wibox.widget({
    markup = ui.colorize_text(due_date, beautiful.fg_sub),
    font = beautiful.font_name .. "11",
    halign = "right",
    align = "center",
    forced_width = dpi(130),
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    taskname,
    nil,
    due,
    layout = wibox.layout.align.horizontal,
  })
end

local function create_all_tasks(tag, project, widget)
  local cmd = "task tag:"..tag.." proj:'"..project.."' status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local empty_json = "[\n]\n"
    if stdout ~= empty_json and stdout ~= "" then
      local tasklist = json.decode(stdout)
      for i, _ in ipairs(tasklist) do
        local desc = tasklist[i]["description"]
        local due  = format_due_date(tasklist[i]["due"])
        print(desc .. due)
        widget:add(create_task(desc, due))
      end
    end
  end)
end

-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀ █░█ █▀▄▀█ █▀▄▀█ ▄▀█ █▀█ █▄█ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    ▄█ █▄█ █░▀░█ █░▀░█ █▀█ █▀▄ ░█░ 
local function create_project_summary(project_name, tag)

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

  local tasks = wibox.widget({
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  })
  create_all_tasks(tag, project_name, tasks)

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
      top = dpi(10),
      bottom = dpi(18),
      left = dpi(25),
      right = dpi(25),
      widget = wibox.container.margin,
    },
    forced_width = dpi(500),
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
    local fuck = {}
    for i = 1, #projects do
      table.insert(fuck, create_project_summary(projects[i]["name"], tag))
    end
    widget:reset()
    for i = 1, #fuck do
      widget:add(fuck[i])
    end
  end)
end

