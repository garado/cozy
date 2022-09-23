
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local nav_tasks = area:new({ name = "tasks" })

-- import
local tag_list, nav_tags = require("ui.dash.tasks.taglist")()
local currently_selected = "mech"
local project_list = wibox.widget({
  {
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  },
  {
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(15),
  layout = wibox.layout.fixed.horizontal,
})
require("ui.dash.tasks.project")("mech", project_list)

nav_tasks:append(nav_tags)

-- Assemble
local tasks_dashboard = wibox.widget({
  {
    {
      tag_list,
      layout = wibox.layout.fixed.vertical,
    },
    project_list,
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

-- this signal is emitted in a taskwarrior hook
-- instructions to configure this are in the install guide
awesome.connect_signal("widget::update_tasks", function()
  require("ui.dash.tasks.project")(currently_selected, project_list)
  project_list:emit_signal("widget::redraw_needed")
end)

-- Change projects shown whenever the tag is changed
awesome.connect_signal("tasks::tag_selected", function(tag)
  currently_selected = tag
  require("ui.dash.tasks.project")(tag, project_list)
end)

return function()
  return tasks_dashboard, nav_tasks
end
