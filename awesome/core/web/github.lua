
-- █▀▀ █ ▀█▀ █░█ █░█ █▄▄ 
-- █▄█ █ ░█░ █▀█ █▄█ █▄█ 

-- Credit: Kasper24

local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local core    = require("helpers.core")

local github = { }
local instance = nil

---------------------------------------------------------------------

local UPDATE_INTERVAL = 60 * 3 -- 5 mins
local PATH = gfs.get_cache_dir("github")


---------------------------------------------------------------------

function github:new()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, github, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
