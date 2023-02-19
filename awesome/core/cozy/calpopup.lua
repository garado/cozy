
-- █▀▀ ▄▀█ █░░ █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▀█ █▄▄ █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Handles backend for calpopup, a popup window used for
-- adding and modifying events.

local cozy    = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")

local calpopup = {}
local instance = nil

function calpopup:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function calpopup:close()
  local cpop_ui = require("apps.dash.agenda.calpopup")
  awful.screen.disconnect_for_each_screen(cpop_ui)
  self:emit_signal("setstate::close")
  self.visible = false
end

function calpopup:open()
  local cpop_ui = require("apps.dash.agenda.calpopup")
  awful.screen.connect_for_each_screen(cpop_ui)
  self:emit_signal("setstate::open")
  self.visible = true
end

function calpopup:new()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, calpopup, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
