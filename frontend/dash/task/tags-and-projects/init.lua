
-- ▀█▀ ▄▀█ █▀▀ █▀    ▄▀█ █▄░█ █▀▄    █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█    █▀█ █░▀█ █▄▀    █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local header = require("frontend.widget.dash.header")
local task  = require("backend.system.task")
local keynav = require("modules.keynav")

local sidebar, nav_tags, nav_projects = require(... .. ".sidebar")()
local tasklist_header = require(... .. ".tasklist.header")
local tasklist_body   = require(... .. ".tasklist.list")
local tasklist_details = require(... .. ".tasklist.details")
local tasklist_prompt = require(... .. ".tasklist.prompt")

local taskheader

local nav_tags_projects = keynav.area({
  name = "nav_tags_projects",
  items = {
    nav_tags,
    nav_projects,
    tasklist_body.area,
  },
  keys = {
    ["Shift_R!"] = function() -- Shift_R + 1
      task:emit_signal("page::switch::tags_and_projects")
    end,
    ["Shift_R@"] = function() -- Shift_R + 2
      task:emit_signal("page::switch::view_all")
    end
  }
})

local _tasklist = wibox.widget({
  {
    tasklist_header,
    ui.vpad(dpi(8)),
    layout = wibox.layout.fixed.vertical,
  },
  {
    tasklist_body,
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  {
    {
      -- NOTE: If you don't have 2 layoutboxes like this and you instead have details/prompt
      -- in the same layoutbox and set spacing = dpi(10), tasklist_prompt will move around when you
      -- toggle the visibility of details. very annoying
      {
        tasklist_details,
        ui.vpad(dpi(10)),
        layout = wibox.layout.fixed.vertical,
      },
      tasklist_prompt,
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(5),
    widget  = wibox.container.margin,
  },
  spacing = dpi(10),
  layout  = wibox.layout.align.vertical,
})

local tasklist = ui.dashbox(_tasklist)

local content = wibox.widget({
  sidebar,
  tasklist,
  forced_width = dpi(2000),
  layout = wibox.layout.ratio.horizontal,
})
content:adjust_ratio(1, 0, 0.25, 0.75)

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

task:connect_signal("task::show_tasklist", function() end)
task:connect_signal("ready::dependencies", function() end)

return function()
  return content, nav_tags_projects
end
