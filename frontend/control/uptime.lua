
-- █░█ █▀█ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄█ █▀▀ ░█░ █ █░▀░█ ██▄ 

local ui = require("utils.ui")
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local control = require("backend.cozy.control")

local widget = ui.textbox({
  text = "",
  color = beautiful.neutral[200],
})

control:connect_signal("setstate::open", function()
  local cmd = 'bash -c "uptime -p"'
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local text = " " .. stdout
    text = string.gsub(text, "up ", "")
    text = string.gsub(text, " day[s]?", "d")
    text = string.gsub(text, " hour[s]?", "h")
    text = string.gsub(text, " minute[s]?", "m")
    text = string.gsub(text, ",", "")
    widget:update_text(text)
  end)
end)

return widget
