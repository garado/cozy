
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

local gobject = require("gears.object")
local gtable = require("gears.table")
-- local control = require("core.cozy.control")
-- local dash = require("core.cozy.dash")
-- local themeswitcher = require("core.cozy.themeswitcher")

local cozy = { }
local instance = nil

---------------------------------------------------------------------

function cozy:close_all()
  require("core.cozy.dash"):close()
  require("core.cozy.control"):close()
  require("core.cozy.themeswitcher"):close()
end

-- function cozy:new()
-- end

local function new()
  local ret = gobject{}
  gtable.crush(ret, cozy, true)
  ret._private = {}
  -- ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
