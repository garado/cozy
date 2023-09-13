
-- ▀█▀ █ █▀▄▀█ █▀▀ 
-- ░█░ █ █░▀░█ ██▄ 

-- Time-tracking widget for dashboard.

local ui    = require("utils.ui")
local wibox = require("wibox")
local timew = require("backend.system.time")

local path = ...

local contents = wibox.widget({
  require(path .. ".inactive"),
  widget = wibox.container.place,
})

timew:connect_signal("tracking::active", function()
  contents.widget = require(path .. ".active")
end)

timew:connect_signal("tracking::inactive", function()
  contents.widget = require(path .. ".inactive")
end)

return ui.dashbox_v2(contents)
