
-- █░█ █▀▄ █▀▀ █░█    █▀█ █░█ █░░ █▀▀ █▀ 
-- █▄█ █▄▀ ██▄ ▀▄▀    █▀▄ █▄█ █▄▄ ██▄ ▄█ 

-- Notifications that trigger with udev rules.

local awful = require("awful")
local naughty = require("naughty")

awesome.connect_signal("udev::bluetooth", function()
end)

awesome.connect_signal("module::brightness", function()
  awful.spawn.easy_async_with_shell("brightnessctl get",
    function(stdout)
      local val = string.gsub(stdout, '%W','')
      val = tonumber(val)
      val = (val * 100) / 255
      val = math.floor(val, 0)

      if not brightnotif then
        brightnotif = naughty.notification {
          title = "Brightness",
          app_name = "System notification",
          message = "Brightness at " .. val .. "%",
          auto_reset_timeout = true,
          timeout = 1.25,
        }
        brightnotif:connect_signal("destroyed", function()
          brightnotif = nil
        end)
      else
        brightnotif.message = "Brightness at " .. val .. "%"
      end
    end)
end)
