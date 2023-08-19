
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 

-- Manages state (open/closed) for control center.

local cozy    = require("backend.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")

local control = {}
local instance = nil

---------------------------------------------------------------------

function control:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function control:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function control:open()
  cozy:close_all_except("control")
  self:emit_signal("setstate::open")
  self.visible = true
end

function control:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, control, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
