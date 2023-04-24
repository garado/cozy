
-- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀ █▀ 
-- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█ ▄█ 

-- Handles backend for bookmarks applet.

local cozy    = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local marks   = require("cozyconf.bookmarks")

local bookmarks = {}
local instance = nil

---------------------------

function bookmarks:find_links(t)
  for _, v in pairs(t) do
    if type(v) == "table" then
      self:find_links(v)
    end

    if v.link then
      self.data[v.title] = { v.link }
    end
  end
end

---------------------------

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
  self.data = {}
  self.curmatches = {}

  self.LINK = 1
  self.NAVITEM = 2
  self.WIBOX = 3

  -- Enum for accessing bookmarks config data
  self._TITLE = 1
  self._LINK  = 2
  self._ICON  = 3
  self._WIBOX = 4

  self:find_links(marks)
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
