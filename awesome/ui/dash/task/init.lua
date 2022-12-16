
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀    █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- ░█░ █▀█ ▄█ █░█ ▄█    █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local tag_list, nav_tags      = require(... .. ".tags")()
local projects, nav_projects  = require(... .. ".projects")()
local tasks, nav_tasklist     = require(... .. ".tasks")()
local header                  = require(... .. ".header")

--------

-- Keyboard navigation
local nav_tasks   = area:new({ name = "tasks" })
local nav_sidebar = area:new({ name = "sidebar", circular = true })
nav_sidebar:append(nav_tags)
nav_sidebar:append(nav_projects)
nav_tasks:append(nav_sidebar)
--nav_tasks:append(nav_tasklist)

--------

-- Assemble UI
local sidebar = wibox.widget({
  tag_list,
  projects,
  -- stats,
  spacing = dpi(15),
  forced_height = dpi(730),
  layout = wibox.layout.ratio.vertical,
})
sidebar:adjust_ratio(2, unpack({0.4, 0.4, 0.2}))

local tasks_dashboard = wibox.widget({
  {
    sidebar,
    {
      {
        header, --overview,
        --prompt,
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
