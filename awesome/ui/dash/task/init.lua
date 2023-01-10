
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
local tasklist, nav_tasklist  = require(... .. ".tasklist.tasks")()
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

local colorize = require("helpers.ui").colorize_text

local sidebar = wibox.widget({
  wibox.widget({
    markup = colorize("Questlog", beautiful.fg),
    font   = beautiful.alt_xlarge_font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  }),
  tag_list,
  projects,
  -- stats,
  spacing = dpi(15),
  forced_height = dpi(730),
  layout = wibox.layout.ratio.vertical,
})
-- sidebar:adjust_ratio(2, unpack({0.4, 0.4, 0.2}))
sidebar:adjust_ratio(2, unpack({0.075, 0.425, 0.5}))

local rightside = wibox.widget({
  {
    {
      header,
      vpad(dpi(15)),
      tasklist,
      layout = wibox.layout.fixed.vertical,
    },
    top     = dpi(15),
    bottom  = dpi(20),
    left    = dpi(25),
    right   = dpi(25),
    widget  = wibox.container.margin,
  },
  forced_width = dpi(800),
  bg = beautiful.dash_widget_bg,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

local tasks_dashboard = wibox.widget({
  {
    { -- needs its own layout box to prevent some weird layout issues
      sidebar,
      layout = wibox.layout.fixed.vertical,
    },
    {
      {
        rightside,
        prompt,
        layout = wibox.layout.fixed.vertical,
      },
      left = dpi(10),
      right = dpi(15),
      widget = wibox.container.margin,
    },
    spacing = dpi(15),
    fill_space = true,
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(15),
  widget = wibox.container.margin,
})

return function()
  return tasks_dashboard, nav_tasks
end
