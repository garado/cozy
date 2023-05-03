
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

local gobject = require("gears.object")
local gtable  = require("gears.table")

local task = {}
local instance = nil

---------------------------------------------------------------------

require(... .. ".interface")(task)
require(... .. ".signal")(task)
require(... .. ".ui")(task)

function task:dbprint(...)
  if self.debug_print then
    print(...)
  end
end

---------------------------------------------------------------------

function task:new()
  self.debug_print = true
  self:signal_setup()
  self:ui_signal_setup()
  self:fetch_tags()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, task, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
