
-- █▄▄ █▀█ █ █▀▀ █░█ ▀█▀ █▄░█ █▀▀ █▀ █▀   █▄░█ █▀█ ▀█▀ █ █▀▀ █▀
-- █▄█ █▀▄ █ █▄█ █▀█ ░█░ █░▀█ ██▄ ▄█ ▄█   █░▀█ █▄█ ░█░ █ █▀░ ▄█

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
          category = "device",
          message = "Brightness at " .. val .. "%",
          auto_reset_timeout = true,
          timeout = 1.25,
        }
      else
        brightnotif:destroy()
        brightnotif = naughty.notification { 
          title = "Brightness",
          app_name = "System notification",
          category = "device",
          message = "Brightness at " .. val .. "%",
          auto_reset_timeout = true,
          timeout = 1.25,
        }
      end
    end)
end)
