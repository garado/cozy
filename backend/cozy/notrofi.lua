

-- █▄░█ █▀█ ▀█▀    █▀█ █▀█ █▀▀ █
-- █░▀█ █▄█ ░█░    █▀▄ █▄█ █▀░ █

-- Manages state for Not Rofi (app launcher/window switcher)
-- Implementation guided by bling's app launcher

local cozy    = require("backend.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")

local notrofi = {}
local instance = nil

---------------------------------------------------------------------

--- @method generate_apps
-- @brief Populate all_entries with all searchable apps
function notrofi:generate_apps()
end

---------------------------------------------------------------------

function notrofi:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function notrofi:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function notrofi:open()
  cozy:close_all_except("notrofi")
  self:emit_signal("setstate::open")
  self.visible = true
end

function notrofi:new()
  self.visible = false
  -- self:generate_apps()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, notrofi, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
