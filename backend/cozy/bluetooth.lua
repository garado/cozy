
-- █▄▄ █░░ █░█ █▀▀ ▀█▀ █▀█ █▀█ ▀█▀ █░█ 
-- █▄█ █▄▄ █▄█ ██▄ ░█░ █▄█ █▄█ ░█░ █▀█ 

-- Manages state (open/closed) for Bluetooth popup.

local cozy    = require("backend.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local strutil = require("utils.string")

local bluetooth = {}
local instance = nil

---------------------------------------------------------------------

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

---------------------------------------------------------------------

function bluetooth:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function bluetooth:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function bluetooth:open()
  cozy:close_all_except("bluetooth")
  self:emit_signal("setstate::open")
  self.visible = true
end

function bluetooth:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, bluetooth, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
