
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

-- Handles backend for dashboard.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local dash = { }
local instance = nil

---------------------------------------------------------------------

function dash:toggle()
  if self._private.visible then
    self:close()
  else
    self:open()
  end
end

function dash:close()
  self:emit_signal("updatestate::close")
  self._private.visible = false
end

function dash:open()
  cozy:close_all()
  self:emit_signal("updatestate::open")
  self._private.visible = true
end

function dash:new()
  self._private = {}
  self._private.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, dash, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
