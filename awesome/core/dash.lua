
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

-- Handles backend for dashboard.

local gobject = require("gears.object")
local gtable = require("gears.table")

local dash = { }
local instance = nil

---------------------------------------------------------------------

function ledger:new()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, ledger, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
