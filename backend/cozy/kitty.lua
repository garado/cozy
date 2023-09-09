
-- █▄▀ █ ▀█▀ ▀█▀ █▄█    █▀ █▀▀ █▀ █▀ █ █▀█ █▄░█ 
-- █░█ █ ░█░ ░█░ ░█░    ▄█ ██▄ ▄█ ▄█ █ █▄█ █░▀█ 

-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ 
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ 

-- Launcher for Kitty sessions

local cozy    = require("backend.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")

local kitty = {}
local instance = nil

function kitty:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function kitty:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function kitty:open()
  cozy:close_all_except("kitty")
  self:emit_signal("setstate::open")
  self.visible = true
end

function kitty:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, kitty, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
