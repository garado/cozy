
-- █▀▄ ▄▀█ █▀ █░█ ▀   █▀▄▀█ ▄▀█ █ █▄░█
-- █▄▀ █▀█ ▄█ █▀█ ▄   █░▀░█ █▀█ █ █░▀█

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local Area = require("modules.keynav.area")

local nav_main = Area:new({ name = "main" })

-- import dash widgets
local nav_habit, habit = require("ui.dash.main.habit")()
local nav_timewarrior, timewarrior = require("ui.dash.main.timewarrior")()

local profile = require("ui.dash.main.profile")
local events = require("ui.dash.main.events")
local tasks = require("ui.dash.main.tasks")
local music = require("ui.dash.main.music_player")
local monthly_spending = require("ui.dash.main.monthly_spending")
local timedate = require("ui.dash.main.timedate")
local goals = require("ui.dash.main.goals")

nav_main:append(nav_timewarrior)
nav_main:append(nav_habit)

-- unused widgets
-- local links = require("ui.dash.main.links")
-- local fetch = require("ui.dash.main.fetch")
-- local pomodoro = require("ui.dash.main.pomodoro")

-- width of widgets is set here
-- height of widgets is set within widget itself
local widget = wibox.widget({
  {
    {
      profile,
      timedate,
      goals,
      music,
      forced_width = dpi(350),
      expand = true,
      layout = wibox.layout.fixed.vertical,
    },
    {
      events,
      tasks,
      monthly_spending,
      forced_width = dpi(550),
      layout = wibox.layout.fixed.vertical,
    },
    {
      timewarrior,
      --pomodoro,
      habit,
      forced_width = dpi(400),
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
  },
  bg = beautiful.dash_bg,
  widget = wibox.container.background,
}) -- end widget

return function()
  return widget, nav_main
end
