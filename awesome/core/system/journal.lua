
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local core    = require("helpers.core")

local journal   = { }
local instance  = nil

-------------------------

--- Call jrnl command to extract entries, then store them in a table.
function journal:parse_entries()
  local cmd = "jrnl -to today --short -n 20"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local lines = core.split('\r\n', stdout)

    local entries = {}
    for i = 1, #lines do
      local date  = string.sub(lines[i], 1, 10)
      local time  = string.sub(lines[i], 12, 16)
      local title = string.sub(lines[i], 18, -1)

      local entry = {}
      entry[#entry+1] = date
      entry[#entry+1] = time
      entry[#entry+1] = title

      if entry[1] and entry[2] and entry[3] then
        entries[#entries+1] = entry
      end
    end

    self.entries = entries
    self:emit_signal("ready::entries")
  end)
end

function journal:get_entry(num)
  return self.entries[num]
end

function journal:unlock()
  self.is_locked = false
end

function journal:lock()
  self.is_locked = true
end

-------------------------

function journal:new()
  self.is_locked = true

  self.date   = 1 -- Enum for accessing entry fields
  self.time   = 2
  self.title  = 3

  self:parse_entries()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, journal, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
