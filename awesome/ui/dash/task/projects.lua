
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀    █░░ █ █▀ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░    █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")
local dpi       = require("beautiful.xresources").apply_dpi
local colorize  = require("helpers.ui").colorize_text
local wheader   = require("helpers.ui").create_dash_widget_header
local task      = require("core.system.task")
local remove_pango = require("helpers.dash").remove_pango

local area = require("modules.keynav.area")
local taskbox = require("modules.keynav.navitem").Taskbox
local tasks_textbox = require("modules.keynav.navitem").Tasks_Textbox

-- █▄▀ █▀▀ █▄█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █░█ ██▄ ░█░ █▄█ █▄█ █▀█ █▀▄ █▄▀ 
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

-- █░█ █ 
-- █▄█ █ 
local project_list = wibox.widget({
  spacing = dpi(5),
  layout = wibox.layout.flex.vertical,
})

local projects_widget = wibox.widget({
  {
    {
      {
        wheader("Projects"),
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

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function create_project_button_markup(tag, project)
  local per = task:get_proj_completion_percentage(tag, project)
  local text = project.." ("..per.. "%)"
  return colorize(text, beautiful.fg)
end

local function create_project_button(tag, project, index)
  local markup = create_project_button_markup(tag, project)
  local textbox = wibox.widget({
    id      = project,
    markup  = markup,
    align   = "center",
    font    = beautiful.base_small_font,
    forced_height = dpi(20),
    widget  = wibox.widget.textbox,
  })

  local nav_project = tasks_textbox:new(textbox)
  nav_project.index = index

  function nav_project:select_on()
    self.selected = true
    local text    = remove_pango(self.widget.text)
    local mkup    = colorize(text, beautiful.main_accent)
    self.widget:set_markup_silently(mkup)
  end

  function nav_project:select_off()
    self.selected = false
    local text    = remove_pango(self.widget.text)
    local mkup    = colorize(text, beautiful.fg)
    self.widget:set_markup_silently(mkup)
  end

  function nav_project:release()
    task:emit_signal("selected::project", project)
  end

  return textbox, nav_project
end

task:connect_signal("project_list::update_all", function(_, tag)
  project_list:reset()
  nav_projects:remove_all_items()
  nav_projects:reset()
  local index = 1
  for project, _ in pairs(task:get_projects(tag)) do
    local textbox, nav = create_project_button(tag, project, index)
    project_list:add(textbox)
    nav_projects:append(nav)
    index = index + 1
  end
end)

task:connect_signal("project_list::update", function(_, tag, project)
  print(project)
  print(project_list)
  local textbox = project_list.children[1]:get_children_by_id(project)[1]

  if not textbox then
    print('error: textbox wibox is nil for '..tag..', '..project)
    return
  end

  local markup = create_project_button_markup(tag, project)
  textbox:set_markup_silently(markup)
end)

task:connect_signal("project_list::add", function(_, project)
end)

return function()
  return projects_widget, nav_projects
end
