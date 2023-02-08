
-- █▀▄ ▄▀█ █▀ █░█ ▀   █▀▄▀█ ▄▀█ █ █▄░█
-- █▄▀ █▀█ ▄█ █▀█ ▄   █░▀░█ █▀█ █ █░▀█

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local habit, nav_habit = require(... .. ".habit")()
local time, nav_time   = require(... .. ".timewarrior")()
local bus, nav_bus     = require(... .. ".bus")()

local profile   = require(... .. ".profile")
local events    = require(... .. ".events")
local tasks     = require(... .. ".tasks")
local music     = require(... .. ".music")
local goals     = require(... .. ".goals")
local ledger    = require(... .. ".ledger")
local timedate  = require(... .. ".timedate")
local github    = require(... .. ".github")

local nav_main = area({
  name     = "main",
  children = {
    nav_bus,
    nav_time,
    nav_habit,
  }
})

-- width of widgets is set here
-- height of widgets is set within widget itself
local widget = wibox.widget({
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
    bus,
    -- ledger,
    forced_width = dpi(550),
    layout = wibox.layout.fixed.vertical,
  },
  {
    time,
    habit,
    github,
    forced_width = dpi(400),
    layout = wibox.layout.fixed.vertical,
  },
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return widget, nav_main
end
