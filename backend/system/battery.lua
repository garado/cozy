
-- █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█ 
-- █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░ 

-- Instantiates UPower module. Responsible for generating notifications.
-- Still needs some work.

local naughty = require("naughty")
local upower  = require("modules.upower")

local curstate, prevstate, prevpercent
local batnotif
local init = true

-- Upower Glib device state values
local CHARGING = 1
local DISCHARGING = 2
local FULLY_CHARGED = 4
local PENDING_CHARGE = 5

--- Ensures only one battery notification is active at any given time.
local function notify(msg)
  if not batnotif then
    batnotif = naughty.notification {
      title = "Battery status",
      app_name = "System",
      message = msg,
      auto_reset_timeout = true,
      timeout = 2,
    }
    batnotif:connect_signal("destroyed", function()
      batnotif = nil
    end)
  else
    batnotif.message = msg
  end
end

-- TODO: Make this a config option
local battery_listener = upower({
  device_path    = "/org/freedesktop/UPower/devices/battery_BAT0",
	instant_update = true,
})

battery_listener:connect_signal("upower::update", function(_, device)
  -- Don't give notification when AwesomeWM restarts
  if init then
    prevstate = device.state
    init = false
    return
  end

  curstate = device.state
	awesome.emit_signal("signal::battery", device.percentage, device.state)

  if curstate == DISCHARGING and prevstate ~= DISCHARGING then
    notify("Discharging")
  elseif curstate == CHARGING and prevstate ~= CHARGING then
    notify("Charging")
  elseif curstate == PENDING_CHARGE and prevstate ~= PENDING_CHARGE then
    notify("Charge holding")
  elseif curstate == FULLY_CHARGED and prevstate ~= FULLY_CHARGED then
    notify("Fully charged")
  end

  if prevpercent and (prevpercent > 20 and device.percentage <= 20) then
    notify("Battery " .. device.percentage)
  elseif prevpercent and (prevpercent > 10 and device.percentage <= 10) then
    notify("Battery low: " .. device.percentage)
  end

  prevstate = curstate
  prevpercent = device.percentage
end)

