
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local task  = require("backend.system.task")

local projectlist = wibox.widget({
  ui.textbox({
    text  = "Projects",
    align = "center",
    font  = beautiful.font_bold_m,
  }),
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})

function projectlist:reset()
  for i = 2, #self.children do
    self:remove(i)
  end
end

function projectlist:add_project(project)
  local t = ui.textbox({
    text  = project,
    align = "center",
  })

  t.selected = false

  t.select_props = {
    fg    = beautiful.primary[400],
    fg_mo = beautiful.primary[500],
  }

  t.deselect_props = {
    fg    = beautiful.fg,
    fg_mo = beautiful.neutral[300],
  }

  t.props = t.deselect_props

  t:connect_signal("mouse::enter", function()
    t:update_color(t.props.fg_mo)
  end)

  t:connect_signal("mouse::leave", function()
    t:update_color(t.props.fg)
  end)

  function t:update()
    t.props = t.selected and t.select_props or t.deselect_props
  end

  t:connect_signal("button::press", function()
    t.selected = not t.selected
    t:update()
    t:update_color(t.props.fg)
  end)

  self:add(t)
end

task:connect_signal("ready::projects", function(_, tag, projects)
  for i = 1, #projects do
    projectlist:add_project(projects[i])
  end
end)

return function()
  return ui.dashbox(projectlist)
end
