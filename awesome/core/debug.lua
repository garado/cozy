
-- █▀▄ █▀▀ █▄▄ █░█ █▀▀ 
-- █▄▀ ██▄ █▄█ █▄█ █▄█ 

-- Simple debug utilities

local gobject = require("gears.object")
local gtable  = require("gears.table")

local debug = { }

---------------------------------------------------------------------

function debug:print(msg)
  if self:state() then
    print(msg)
  end
end

function debug:on()
  self._private.debug_active = true
end

function debug:off()
  self._private.debug_active = false
end

function debug:state()
  return self._private.debug_active
end

---------------------------------------------------------------------

function debug:new()
  self._private.debug_active = true
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, debug, true)
  ret._private = {}
  ret:new()
  return ret
end

return new()
