
-- █░█ █▀█ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄█ █▀▀ ░█░ █ █░▀░█ ██▄ 

local awful = require("awful")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local wibox = require("wibox")

return function(ctrl_obj)
  local widget = wibox.widget({
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local function update_uptime()
    local cmd = 'bash -c "uptime -p"'
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local text = colorize(" " .. stdout, beautiful.ctrl_uptime)
      text = string.gsub(text, "up ", "")
      text = string.gsub(text, " day[s]?", "d")
      text = string.gsub(text, " hour[s]?", "h")
      text = string.gsub(text, " minute[s]?", "m")
      text = string.gsub(text, ",", "")
      widget:set_markup_silently(text)
    end)
  end

  ctrl_obj:connect_signal("ctrl::opened", function()
    update_uptime()
  end)

  return widget
end
