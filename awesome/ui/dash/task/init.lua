
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- Frontend for Taskwarrior.

local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local task = require("core.system.task")
local keynav = require("modules.keynav")
local ui = require("helpers.ui")

local tag_list, nav_tags = require(... .. ".tags")()
local project_list, nav_projects = require(... .. ".projects")()
local tasklist, nav_tasklist = require(... .. ".tasklist")()
local header = require(... .. ".header")
local prompt = require(... .. ".prompt")

local nav_tasks = keynav.area({
  name = "tasks",
  children = {
    nav_tags,
    nav_projects,
    nav_tasklist,
  },
})

task:connect_signal("tasklist::switch_index", function(_, index)
  nav_tasklist:set_curr_item(index)
  nav_tasks.nav:set_area("tasklist")
end)

----------

local sidebar = wibox.widget({
  {
    markup = ui.colorize("Questlog", beautiful.fg),
    font   = beautiful.alt_large_font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  },
  tag_list,
  project_list,
  forced_width = dpi(300),
  layout = wibox.layout.fixed.vertical,
})

local main_contents = wibox.widget({
  {
    {
      header,
      ui.vpad(dpi(15)),
      tasklist,
      layout = wibox.layout.fixed.vertical,
    },
    top     = dpi(15),
    bottom  = dpi(20),
    left    = dpi(25),
    right   = dpi(25),
    widget  = wibox.container.margin,
  },
  bg     = beautiful.dash_widget_bg,
  shape  = gears.shape.rounded_rect,
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
        main_contents,
        prompt,
        layout = wibox.layout.fixed.vertical,
      },
      left   = dpi(10),
      right  = dpi(15),
      widget = wibox.container.margin,
    },
    fill_space = true,
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
  },
  margins = dpi(15),
  widget  = wibox.container.margin,
})

return function()
  return tasks_dashboard, nav_tasks
end
