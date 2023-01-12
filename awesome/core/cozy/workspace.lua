
-- █░█░█ █▀█ █▀█ █▄▀ █▀ █▀█ ▄▀█ █▀▀ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ █▄█ █▀▄ █░█ ▄█ █▀▀ █▀█ █▄▄ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- Handles backend for workspace switcher.

local cozy    = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")

local wspace = { }
local instance = nil

---------------------------------------------------------------------

function wspace:toggle()
  if self._private.visible then
    self:close()
  else
    self:open()
  end
end

function wspace:close()
  self:emit_signal("state::close")
  self._private.visible = false
end

function wspace:open()
  cozy:close_all()
  self:emit_signal("state::open")
  self._private.visible = true
end

function wspace:new()
  self._private = {}
  self._private.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, wspace, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
