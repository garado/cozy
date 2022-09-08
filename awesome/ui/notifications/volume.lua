
-- █░█ █▀█ █░░ █░█ █▀▄▀█ █▀▀   █▄░█ █▀█ ▀█▀ █ █▀▀ █▀
-- ▀▄▀ █▄█ █▄▄ █▄█ █░▀░█ ██▄   █░▀█ █▄█ ░█░ █ █▀░ ▄█

local awful = require("awful")
local naughty = require("naughty")

local volnotif

awesome.connect_signal("module::volume", function()
  awful.spawn.easy_async_with_shell("pamixer --get-volume-human",
    function(stdout)
      local val = string.gsub(stdout, '[\n\r]','')

      if volnotif and volnotif.is_expired then
        volnotif:destroy()
        volnotif = nil
      end

      if not volnotif then
        volnotif = naughty.notification {
          title = "Volume",
          app_name = "System notification",
          message = "Volume at " .. val,
          timeout = 1.25,
          auto_reset_timeout = true,
        }
        awesome.emit_signal("volumefuck", volnotif)
        volnotif:connect_signal("destroyed", function()
          volnotif = nil
        end)
      else
        volnotif.message = "Volume at " .. val
      end
    end)
end)

