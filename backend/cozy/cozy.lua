
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- Can control state of all of Cozy's popups. Used primarily for
-- closing all popups at once.
-- To avoid circular dependencies we have require submodules inside of
-- functions.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")

local cozy = {}
local instance = nil

function cozy:close_all()
  require("backend.cozy.dash"):close()
  require("backend.cozy.themeswitch"):close()
end

-- TODO: Could be improved
function cozy:close_all_except(exception)
  if exception == "dash" then
    require("backend.cozy.themeswitch"):close()
  elseif exception == "themeswitch" then
    require("backend.cozy.dash"):close()
  end
end

return cozy
