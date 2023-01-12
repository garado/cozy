
-- █▀▀ ▄▀█ █░░ █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▀█ █▄▄ █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Handles backend for calendar add event popup.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local calpopup = { }
local instance = nil

---------------------------------------------------------------------

function calpopup:toggle()
  print('bitch')
  if self._private.visible then
    self:close()
  else
    self:open()
  end
end

function calpopup:close()
  self:emit_signal("close")
  self._private.visible = false
end

function calpopup:open()
  self:emit_signal("open")
  self._private.visible = true
end

function calpopup:new()
  self._private = {}
  self._private.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, calpopup, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
