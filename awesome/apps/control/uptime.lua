
-- █░█ █▀█ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄█ █▀▀ ░█░ █ █░▀░█ ██▄ 

local beautiful = require("beautiful")
local awful   = require("awful")
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local control = require("core.cozy.control")

local widget = wibox.widget({
  align  = "left",
  font   = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
})

local function update_uptime()
  local cmd = 'bash -c "uptime -p"'
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local text = ui.colorize(" " .. stdout, beautiful.ctrl_uptime)
    text = string.gsub(text, "up ", "")
    text = string.gsub(text, " day[s]?", "d")
    text = string.gsub(text, " hour[s]?", "h")
    text = string.gsub(text, " minute[s]?", "m")
    text = string.gsub(text, ",", "")
    widget:set_markup_silently(text)
  end)
end

control:connect_signal("setstate::open", function()
  update_uptime()
end)

return widget
