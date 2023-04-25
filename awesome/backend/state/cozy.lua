
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- Can control state of all of Cozy's popups. Used primarily for
-- closing all popups at once.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")

local cozy = {}
local instance = nil

function cozy:close_all()
  require("backend.state.dash"):close()
end

function cozy:close_all_except(except)
  if except ~= "dash" then
    require("backend.state.dash"):close()
  end
end

return cozy
