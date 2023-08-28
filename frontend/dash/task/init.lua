
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local header = require("frontend.widget.dash.header")
local keynav = require("modules.keynav")

local tags_projects, nav_tags_projects = require(... .. ".tags-and-projects")()

local taskheader

local content = wibox.widget({
  tags_projects,
  forced_height = dpi(2000),
  widget = wibox.container.margin,
})

local nav_tasks = keynav.area({
  name = "nav_tasks",
  items = {
    nav_tags_projects
  },
  keys = {
    ["Shift_R!"] = function() -- Shift_R + 1
      taskheader:get_pages()[1]:emit_signal("button::press")
    end,
    ["Shift_R@"] = function() -- Shift_R + 2
      taskheader:get_pages()[2]:emit_signal("button::press")
    end,
  },
})

taskheader = header({
  title_text = "Taskwarrior",
  pages = {
    { text = "Tags & projects" },
    { text = "View all" },
  },
  actions = {
    {
      text = "Refresh",
      on_press = function()
      end
    },
    {
      text = "Sync",
      func = function()
        awful.spawn.easy_async_with_shell("task sync", function(stdout, stderr) print(stdout, stderr) end)
      end
    }
  }
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

local container = wibox.widget({
  taskheader,
  content,
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return ui.contentbox(taskheader, content), nav_tasks
end
