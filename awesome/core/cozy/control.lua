
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 

-- Handles backend for control center.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local cozy    = require("core.cozy.cozy")

local control  = {}
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

local function new()
  local ret = gobject{}
  gtable.crush(ret, control, true)
  return ret
end

if not instance then
  instance = new()
end

return instance
