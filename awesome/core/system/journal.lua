
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

-- For interfacing with jrnl.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local core    = require("helpers.core")
local config  = require("config")
local debug   = require("core.debug")

local journal   = { }
local instance  = nil

-------------------------

--- Call jrnl command to extract entries, then store them in a table.
function journal:parse_entries()
  local cmd = "jrnl -to today --short -n 100"
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

--- Call jrnl command to retrieve a specific entry's contents.
function journal:parse_entry_contents(date, title, index)
  local cmd = "jrnl -on " .. date .. " -contains \"" .. title .. "\" | tail -n +2"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    stdout = string.gsub(stdout, "| ", "")
    self:emit_signal("ready::entry_contents", index, stdout)
  end)
end

function journal:get_entry_titles()
  local titles = {}
  for i = 1, #self.entries do
    titles[#titles+1] = self.entries[i][self.title]
  end
  return titles
end

function journal:get_entry(num)
  return self.entries[num]
end

function journal:unlock()
  self.is_locked = false
  self:emit_signal("unlock")
end

function journal:lock()
  self.is_locked = true
end

function journal:try_unlock(input)
  if input == config.journal.password then
    debug:print('journal::try_unlock: correct')
    self:unlock()
  else
    debug:print('journal::try_unlock: incorrect')
  end
end

-------------------------

function journal:new()
  self.is_locked = true

  -- Enum for accessing entry fields
  self.date   = 1
  self.time   = 2
  self.title  = 3

  self:parse_entries()

  self:connect_signal("input_complete", function(_, input)
    self:try_unlock(input)
  end)

  self:connect_signal("entry_selected", function(_, index)
    print('selected entry index '..index)
    local entry = self.entries[index]
    local date  = entry[self.date]
    local title = entry[self.title]
    self:parse_entry_contents(date, title, index)
  end)
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
