
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀ 
-- █▀█ █▀█ █▄█ █ ░█░ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local habit = require("frontend.widget.dash.habit")
local pixela = require("backend.system.pixela")
local conf  = require("cozyconf")

local habits = wibox.widget({
  layout = wibox.layout.fixed.vertical,
})

for i = 1, #conf.habits do
  local h = habit({
    id    = conf.habits[i][1],
    title = conf.habits[i][2],
    frequency = conf.habits[i][3],
  })
  habits:add(h)
end

local widget = wibox.widget({
  {
    habits,
    top    = dpi(20),
    bottom = dpi(20),
    widget = wibox.container.margin,
  },
  shape = ui.rrect(),
  bg = beautiful.neutral[800],
  widget = wibox.container.background,
})

return widget
