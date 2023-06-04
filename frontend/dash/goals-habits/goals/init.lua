
-- █▀▀ █▀█ ▄▀█ █░░ █▀ 
-- █▄█ █▄█ █▀█ █▄▄ ▄█ 

local wibox = require("wibox")
local goals = require("backend.system.goals")
local keynav = require("modules.keynav")

local overview = require(... .. ".overview")
local roadmap  = require(... .. ".roadmap")

local nav_goals = keynav.area({
  name  = "nav_goals",
  items = overview.areas
})

local content = wibox.widget({
  overview,
  layout = wibox.layout.fixed.vertical,
  -----
  area = nav_goals
})

goals:connect_signal("goals::show_roadmap", function()
  content:reset()
  content:add(roadmap)
  content.area:clear()
  content.area:append(roadmap.area)
end)

goals:connect_signal("goals::show_overview", function()
  content:reset()
  content:add(overview)
  content.area:clear()
  content.area:append(overview.areas[1])
  content.area:append(overview.areas[2])
end)

return content
