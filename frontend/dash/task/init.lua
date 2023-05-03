
-- ▀█▀ ▄▀█ █▀ █▄▀ 
-- ░█░ █▀█ ▄█ █░█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local header = require("frontend.widget.dash-header")
local task  = require("backend.system.task")

local projects, nav_projects = require(... .. ".projects")()
local tags,     nav_tags     = require(... .. ".tags")()
local tasklist, nav_tasklist = require(... .. ".tasklist")()

local content = wibox.widget({
  {
    tags,
    projects,
    layout = wibox.layout.fixed.vertical,
  },
  tasklist,
  forced_width = dpi(2000),
  layout = wibox.layout.ratio.horizontal,
})
content:adjust_ratio(1, 0, 0.25, 0.75)

-------------------------

local taskheader = header({
  header_text = "Taskwarrior"
})

taskheader:add_sb("Category")
taskheader:add_sb("Kanban")

local container = wibox.widget({
  taskheader,
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
