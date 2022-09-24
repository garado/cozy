
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Create a fancy-looking list of projects.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local helpers = require("helpers")
local ui = require("helpers.ui")
local math = math
local navtask = require("modules.keynav.navitem").Task
local taskbox = require("modules.keynav.navitem").Taskbox
local area = require("modules.keynav.area")
-- local animation = require("modules.animation")

-- Keyboard navigation
local nav_overview = area:new({
  name = "overview",
  circular = true,
})

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

  local due_date_color = beautiful.fg_sub
  if time_difference < 0 then -- overdue
    due_date_text = due_date_text .. " ago"
    due_date_color = beautiful.red
  else
    due_date_text = "in " .. due_date_text
  end

  return due_date_text, due_date_color
end

-- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
-- ░█░ █▀█ ▄█ █░█ ▄█ 
-- Returns tasks associated with a given project.
local function create_task(name, due_date)
  name = name:gsub("%^l", string.upper)
  local taskname = wibox.widget({
    markup = ui.colorize_text(name, beautiful.fg),
    font = beautiful.font_name .. "12",
    ellipsize = "end",
    forced_width = dpi(410),
    widget = wibox.widget.textbox,
  })

  local due_text, due_color = format_due_date(due_date)
  local due = wibox.widget({
    markup = ui.colorize_text(due_text, due_color or beautiful.fg_sub),
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

return function(task_obj)
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
      markup = helpers.ui.colorize_text(name_text, accent),
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
      markup = helpers.ui.colorize_text("0%", beautiful.fg),
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
    for i = 1, #tasks do
      local task = create_task(tasks[i][desc], tasks[i][due])
      nav_overview:append(navtask:new(task))
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
      forced_width = dpi(320),
      bg = beautiful.dash_widget_bg,
      shape = gears.shape.rounded_rect,
      widget = wibox.container.background,
    })

    -- update progress bar/completion percentage
    local cmd = "task context none ; task tag:"..tag.." project:'"..project.. "' count"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local pending = #tasks
      local total = tonumber(stdout) or 0
      local completed = total - pending
      local percent = math.floor((completed / total) * 100) or 0

      progress_bar.value = percent
      --progress_bar.value = 0
      local markup = helpers.ui.colorize_text(percent.."%", beautiful.fg)
      percent_completion:set_markup_silently(markup)

      -- tag
      local rem = pending.."/"..total.." REMAINING"
      -- local text = string.upper(tag).." - "..rem
      markup = helpers.ui.colorize_text(rem, beautiful.fg)
      project_tag:set_markup_silently(markup)

      -- fun animation!
      --local anim = animation:new({
      --  duration = 1.25,
      --  target = percent,
      --  easing = animation.easing.inOutExpo,
      --  update = function(_, pos)
      --    progress_bar.value = dpi(pos)
      --    markup = helpers.ui.colorize_text(dpi(pos).."%", beautiful.fg)
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
    nav_overview.widget = taskbox:new(widget)
  end)

  return overview, nav_overview
end
