
-- █▀▀ █▀█ ▄▀█ █░░ █▀ 
-- █▄█ █▄█ █▀█ █▄▄ ▄█ 

local beautiful  = require("beautiful")
local awful = require("awful")
local keynav = require("modules.keynav")
local dash = require("backend.cozy.dash")
local wibox = require("wibox")

local overview = require(... .. ".overview")
local details  = require(... .. ".details")

local nav_goals = keynav.area({
  name  = "nav_goals",
  items = { overview.area }
})


local content = wibox.widget({
  overview,
  layout = wibox.layout.fixed.vertical,
  -----
  area = nav_goals
})

dash:connect_signal("goals::show_details", function(_, data)
  content:reset()
  content:add(details)
  content.area:clear()
  content.area:append(details.area)
end)

dash:connect_signal("goals::show_overview", function(_)
  content:reset()
  content:add(overview)
  content.area:clear()
  content.area:append(overview.area)
end)

return content
