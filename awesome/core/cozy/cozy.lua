
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- This handles managing the collective state of all of Cozy's popup windows.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")

local cozy = {}
local instance = nil

function cozy:close_all()
  require("core.cozy.dash"):close()
  require("core.cozy.control"):close()
  require("core.cozy.themeswitcher"):close()
  require("core.cozy.bookmarks"):close()
  require("core.cozy.calpopup"):close()
  awful.keygrabber:stop()
end

function cozy:close_all_except(except)
  if except ~= "dash" then
    require("core.cozy.dash"):close()
  end

  if except ~= "control" then
    require("core.cozy.control"):close()
  end

  if except ~= "themeswitcher" then
    require("core.cozy.themeswitcher"):close()
  end

  if except ~= "bookmarks" then
    require("core.cozy.bookmarks"):close()
  end

  if except ~= "calpopup" then
    require("core.cozy.calpopup"):close()
  end
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, cozy, true)
  return ret
end

if not instance then
  instance = new()
end

return instance
