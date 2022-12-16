
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local area = require("modules.keynav.area")
local navtask = require("modules.keynav.navitem").Task
local overviewbox = require("modules.keynav.navitem").OverviewBox
local animation = require("modules.animation")
local math = math
local dash = require("core.cozy.dash")
local helpers = require("helpers")
local colorize = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date

local task = require("core.system.task")

-- █▄▀ █▀▀ █▄█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄  
-- █░█ ██▄ ░█░ █▄█ █▄█ █▀█ █▀▄ █▄▀  

-- Setting up custom keys is... a little clunky
-- Need to update keynav to make this better
local nav_tasklist
nav_tasklist = area:new({
  name = "tasklist",
  circular = true,
})

-- local keys = require("ui.dash.tasks.keygrabber")(task_obj)
-- keys["h"] = function()
--   local navigator = nav_tasklist.nav
--   navigator:set_area("projects")
-- end
-- nav_tasklist.keys = keys

-- █░█ █
-- █▄█ █

local tasklist_wrapper = wibox.widget({
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
})

local tasklist = wibox.widget({
  spacing = dpi(8),
  layout = wibox.layout.flex.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

local function create_task_wibox(name, due_date, start, id)
  name = name:gsub("%^l", string.upper)
  local taskname_color = start and beautiful.green or beautiful.fg
  local taskname = wibox.widget({
    markup = colorize(name, taskname_color),
    font = beautiful.font_name .. "12",
    ellipsize = "end",
    widget = wibox.widget.textbox,
  })

  local due_text, due_color = format_due_date(due_date)
  local due = wibox.widget({
    markup = colorize(due_text, due_color or beautiful.fg_sub),
    font = beautiful.font_name .. "12",
    halign = "right",
    align = "center",
    widget = wibox.widget.textbox,
  })

  local task_wibox = wibox.widget({
    taskname,
    nil,
    due,
    forced_height = dpi(20),
    layout = wibox.layout.align.horizontal,
  })

  return task_wibox
end

return function()
  return nav_tasklist
end
