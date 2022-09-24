
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

-- Create a fancy-looking list of projects.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local helpers = require("helpers")
local area = require("modules.keynav.area")
local navproj = require("modules.keynav.navitem").Project

local math = math

return function(task_obj)
  local function create_project_header(tag, project, tasks)
    local accent = beautiful.random_accent_color()
    if project == "(none)" or project == "noproj" then
      project = "No project"
    end

    local name_text = project:gsub("^%l", string.upper) -- capitalize 1st letter
    local name = wibox.widget({
      markup = helpers.ui.colorize_text(name_text, accent),
      font = beautiful.alt_font .. "15",
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
      font = beautiful.alt_font .. "Light 15",
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

    local widget = wibox.widget({
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
        top = dpi(15),
        bottom = dpi(20),
        left = dpi(25),
        right = dpi(25),
        widget = wibox.container.margin,
      },
      id = project,
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
      local markup = helpers.ui.colorize_text(percent.."%", beautiful.fg)
      percent_completion:set_markup_silently(markup)

      -- tag
      local rem = pending.."/"..total.." REMAINING"
      -- local text = string.upper(tag).." - "..rem
      markup = helpers.ui.colorize_text(rem, beautiful.fg)
      project_tag:set_markup_silently(markup)

      -- prevent flicker by only drawing when all ui-related async calls have
      -- finished
      task_obj:emit_signal("tasks::projectlist_ready", widget, project)
    end)

    return widget
  end -- end create_project_header

  -- Keyboard navigation
  local nav_projects = area:new({
    name = "projects",
    circular = true,
  })

  local project_list = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  })

  -- json_parsed signal tells us that the data is ready to be
  -- processed
  local fuck = true
  task_obj:connect_signal("tasks::json_parsed", function()
    nav_projects:remove_all_items()
    nav_projects:reset()
    fuck = true

    local tag = task_obj.current_tag
    for project, tasks in pairs(task_obj.projects) do
      create_project_header(tag, project, tasks)
    end
  end)

  -- prevent flicker by only drawing when all ui-related async calls have
  -- finished
  task_obj:connect_signal("tasks::projectlist_ready", function(_, widget, name)
    if fuck then
      project_list:reset()
      fuck = false
    end
    project_list:add(widget)
    nav_projects:append(navproj:new(widget, task_obj, name))
  end)

  return project_list, nav_projects
end
