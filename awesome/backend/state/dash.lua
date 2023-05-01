
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

-- Manages state (open/closed) for dashboard.

local cozy    = require("backend.state.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local ui      = require("utils.ui")

local dash = {}
local instance = nil

---------------------------------------------------------------------

function dash:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function dash:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function dash:open()
  -- cozy:close_all_except("dash")
  self:emit_signal("setstate::open")
  self.visible = true
end

function dash:set_tab(tab_enum)
  self:emit_signal("tab::set", tab_enum)
end

function dash:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, dash, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
