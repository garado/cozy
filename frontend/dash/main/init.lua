
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui    = require("utils.ui")
local dpi   = require("utils.ui").dpi
local beautiful = require("beautiful")
local dashstate = require("backend.state.dash")
local keynav    = require("modules.keynav")
local colorize  = require("utils.ui").colorize
local config    = require("cozyconf")

local greeting = require(... .. ".greeting")
local events = require(... .. ".events")
local tasks  = require(... .. ".duedates")

local profile = require(... .. ".profile")
-- local github  = require(... .. ".github")

local grid = wibox.widget({
  greeting,
  events,
  tasks,
  spacing = dpi(35),
  layout = wibox.layout.fixed.vertical,
})

local widget = wibox.widget({
  grid,
  widget = wibox.container.place
})

return function()
  return widget, false
end
