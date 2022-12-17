
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local area = require("modules.keynav.area")
local vpad = require("helpers.ui").vertical_pad
local task = require("core.system.task")

local tag_list, nav_tags      = require(... .. ".tags")()
local projects, nav_projects  = require(... .. ".projects")()
local tasklist, nav_tasklist  = require(... .. ".tasks")()
local header  = require(... .. ".header")
local prompt  = require(... .. ".prompt")

--------

-- Keyboard navigation
local nav_tasks   = area:new({ name = "tasks" })
local nav_sidebar = area:new({ name = "sidebar", circular = true })
nav_sidebar:append(nav_tags)
nav_sidebar:append(nav_projects)
nav_tasks:append(nav_sidebar)
nav_tasks:append(nav_tasklist)

task:connect_signal("ui::switch_tasklist_index", function(_, index)
  nav_tasklist:set_curr_item(index)
  nav_tasks.nav:set_area("tasklist")
end)

--------

local sidebar = wibox.widget({
  tag_list,
  projects,
  -- stats,
  spacing = dpi(15),
  forced_height = dpi(730),
  layout = wibox.layout.ratio.vertical,
})
sidebar:adjust_ratio(2, unpack({0.4, 0.4, 0.2}))

local rightside = wibox.widget({
  {
    {
      header,
      vpad(dpi(15)),
      {
        -- {
        --   scrollbar_cont,
        --   tasklist,
        --   layout = wibox.layout.align.horizontal,
        -- },
        tasklist,
        height = dpi(800),
        --height = max_tasklist_height,
        widget = wibox.container.constraint,
      },
      layout = wibox.layout.fixed.vertical,
    },
    top = dpi(15),
    bottom = dpi(20),
    left = dpi(25),
    right = dpi(25),
    widget = wibox.container.margin,
  },
  forced_width = dpi(600),
  bg = beautiful.dash_widget_bg,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

local tasks_dashboard = wibox.widget({
  {
    sidebar,
    {
      {
        rightside,
        prompt,
        layout = wibox.layout.fixed.vertical,
      },
      left = dpi(15),
      right = dpi(20),
      widget = wibox.container.margin,
    },
    spacing = dpi(15),
    layout = wibox.layout.align.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

return function()
  return tasks_dashboard, nav_tasks
end
