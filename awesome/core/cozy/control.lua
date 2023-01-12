
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 

-- Handles backend for control center.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")

local control = { }
local instance = nil

---------------------------------------------------------------------

function control:toggle()
  if self._private.visible then
    self:close()
  else
    self:open()
  end
end

function control:close()
  self:emit_signal("updatestate::close")
  self._private.visible = false
end

function control:open()
  cozy:close_all()
  self:emit_signal("updatestate::open")
  self._private.visible = true
end

function control:redraw()
  for i = 1, #self.widgets do
    local path = "ui.control." .. self.widgets[i]
    package.loaded[path] = nil
  end
  -- collectgarbage("collect")
  self:emit_signal("redraw")
end

function control:new()
  self._private = {}
  self._private.visible = false
  self.widgets = {
    "uptime",
    "profile",
    "stats",
    "fetch",
    "picom",
    "quick_actions",
    "power",
  }
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, control, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
