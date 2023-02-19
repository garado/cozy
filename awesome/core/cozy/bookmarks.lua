
-- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀ █▀ 
-- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█ ▄█ 

-- Handles backend for bookmarks applet.

local cozy    = require("core.cozy.cozy")
local config  = require("cozyconf")
local gobject = require("gears.object")
local json    = require("modules.json")
local gtable  = require("gears.table")
local awful   = require("awful")

local bookmarks = { }
local instance = nil

local EMPTY_JSON = "[\n]\n"

function bookmarks:read()
  self.data = {}

  local path = config.bookmarks.path
  local cmd = "cat \"" .. path .. "\""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == EMPTY_JSON or stdout == "" then return end
    self.data = json.decode(stdout)

    -- sort categories alphabetically
    self.catnames = {}
    for cat in pairs(self.data) do
      table.insert(self.catnames, cat)
    end
    table.sort(self.catnames, function(a, b)
      return a < b
    end)

    self:emit_signal("ready::json")
  end)
end

function bookmarks:write()
end

----------------

function bookmarks:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function bookmarks:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function bookmarks:open()
  cozy:close_all_except("bookmarks")
  self:emit_signal("setstate::open")
  self.visible = true
end

function bookmarks:new()
  self.visible = false
  self:read()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, bookmarks, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
