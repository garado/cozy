
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

-- Show list of projects associated with a task

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local box = require("helpers.ui").create_boxed_widget
local wheader = require("helpers.ui").create_dash_widget_header
local colorize = require("helpers.ui").colorize_text
local keynav = require("modules.keynav")
local task = require("backend.system.task")

-- █░█ █ 
-- █▄█ █ 

local project_list = wibox.widget({
  spacing = dpi(7),
  layout = wibox.layout.fixed.vertical,
})

local projects_widget = wibox.widget({
  wheader("Projects"),
  project_list,
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})

local container = box(projects_widget, nil, nil, beautiful.dash_widget_bg)

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local nav_projects = keynav.area({
  name   = "projects",
  widget = keynav.navitem.background({ widget = container.children[1] }),
  hl_persist_on_area_switch = true,
  on_area_changed = function(self)
    self:select_off_recursive()
    for i = 1, #self.items do
      if self.items[i].label == task.focused_project then
        self:set_curr_item(i)
        return
      end
    end
  end
})

local function create_project_item(tag, project, index)
  local per    = task:calc_completion_percentage(tag, project)
  local markup = project.." ("..per.. "%)"

  local textbox = wibox.widget({
    id      = project,
    markup  = colorize(markup, beautiful.fg_0),
    align   = "center",
    font    = beautiful.font_reg_s,
    forced_height = dpi(20),
    widget  = wibox.widget.textbox,
  })

  local nav_project = keynav.navitem.textbox({
    widget  = textbox,
    index   = index,
    label   = project,
    release = function()
      task:emit_signal("selected::project", project)
    end,
  })

  return textbox, nav_project
end

task:connect_signal("projects::update", function(_, tag)
  project_list:reset()
  nav_projects:reset()

  local index  = 1
  local tagdata = task.tags[tag]
  for i = 1, #tagdata.project_names do
    local ptext, pnav = create_project_item(tag, tagdata.project_names[i], index)
    project_list:add(ptext)
    nav_projects:add(pnav)
    index = index + 1
  end
end)

return function()
  return container, nav_projects
end
