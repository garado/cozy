
-- █░█ █▀█ █░░ █░█ █▀▄▀█ █▀▀   █▄░█ █▀█ ▀█▀ █ █▀▀ █▀
-- ▀▄▀ █▄█ █▄▄ █▄█ █░▀░█ ██▄   █░▀█ █▄█ ░█░ █ █▀░ ▄█

-- UNBELIEVABLY JANK
-- couldnt find a cleaner way to replace notification
-- so we're stuck with this bs

local awful = require("awful")
local naughty = require("naughty")
local helpers = require("helpers")
local beautiful = require("beautiful")
local wibox = require("wibox")
local string = string
local math = math 

awesome.connect_signal("module::volume", function()
  awful.spawn.easy_async_with_shell("pamixer --get-volume",
    function(stdout)
      local val = string.gsub(stdout, '%W','')
      val = tonumber(val)

      if not notif then
        notif = naughty.notification { 
          title = "Volume",
          app_name = "System notification",
          category = "device",
          message = "Volume at " .. val .. "%",
          auto_reset_timeout = true,
          timeout = 1.25,
        }
      else
        notif:destroy()
        notif = naughty.notification { 
          title = "Volume",
          app_name = "System notification",
          category = "device",
          message = "Volume at " .. val .. "%",
          auto_reset_timeout = true,
          timeout = 1.25,
        }
      end
    end
  )
end)
