
-- █▄▄ █░░ █░█ █▀▀ ▀█▀ █▀█ █▀█ ▀█▀ █░█ 
-- █▄█ █▄▄ █▄█ ██▄ ░█░ █▄█ █▄█ ░█░ █▀█ 

-- Manages state (open/closed) for Bluetooth popup.

local be = require("utils.backend")
local awful = require("awful")
local strutil = require("utils.string")

local bluetooth = {}

function bluetooth:get_devices()
  local cmd = "bluetoothctl devices"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Clean up data
    local devices = {}
    local lines = strutil.split(stdout, "\r\n")

    -- Always in this format: Device 12:34:20:32:D5:3F BT mouse
    for i = 1, #lines do
      devices[#devices+1] = {}
      devices[i][1] = lines[i]:sub(26)    -- Device name
      devices[i][2] = lines[i]:sub(8, 24) -- MAC address
    end

    self:emit_signal("ready::devices", devices)
  end)
end

return be.create_popup_manager({
  tbl = bluetooth,
  name = "bluetooth",
})
