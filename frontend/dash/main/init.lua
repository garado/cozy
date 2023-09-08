
-- █▀▄▀█ ▄▀█ █ █▄░█    ▀█▀ ▄▀█ █▄▄ 
-- █░▀░█ █▀█ █ █░▀█    ░█░ █▀█ █▄█ 

local wibox      = require("wibox")
local ui         = require("utils.ui")
local dpi        = require("utils.ui").dpi
local beautiful  = require("beautiful")
local keynav     = require("modules.keynav")
local spaceratio = require("utils.layout.spaceratio")

local github    = require(... .. ".github")
local quotes    = require(... .. ".quotes")
local profile   = require(... .. ".profile")
local datetime  = require(... .. ".datetime")
local schedule  = require(... .. ".schedule")
local habits    = require(... .. ".habits")
local time      = require(... .. ".time")
local music     = require(... .. ".music")
local weather   = require(... .. ".weather")

local nav_main   = keynav.area({
  name      = "nav_main",
  autofocus = false,
  items     = {
    time.keynav,
    habits.keynav,
  }
})

local col1 = wibox.widget({
  profile,
  datetime,
  quotes,
  github,
  spacing = beautiful.dash_widget_gap,
  layout = spaceratio.vertical,
})
col1:set_ratio(1, 0.32)
col1:set_ratio(4, 0.25)
-- col1:set_ratio(4, 0.4)

local col2 = wibox.widget({
  schedule,
  music,
  spacing = beautiful.dash_widget_gap,
  layout = wibox.layout.fixed.vertical,
})

local col3 = wibox.widget({
  weather,
  time,
  habits,
  spacing = beautiful.dash_widget_gap,
  layout = spaceratio.vertical,
})
col3:set_ratio(1, 0.25)
col3:set_ratio(3, 0.34)

local content = wibox.widget({
  col1,
  col2,
  col3,
  spacing = beautiful.dash_widget_gap,
  layout = spaceratio.horizontal,
})
content:set_ratio(1, 0.32)
content:set_ratio(2, 0.38)

content = wibox.widget({
  content,
  margins = beautiful.dash_widget_gap / 2,
  widget = wibox.container.margin,
})

return function()
  return content, nav_main
end
