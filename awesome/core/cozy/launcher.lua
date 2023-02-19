
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 

-- Handles backend for launcher.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local launcher = { }
local instance = nil

---------------------------------------------------------------------

function launcher:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function launcher:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function launcher:open()
  cozy:close_all_except()
  self:emit_signal("setstate::open")
  self.visible = true
end

function launcher:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, launcher, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
