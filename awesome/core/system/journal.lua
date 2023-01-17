
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

-- For interfacing with jrnl.

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local core    = require("helpers.core")
local config  = require("config")
local debug   = require("core.debug")
local dash    = require("core.cozy.dash")

local journal   = { }
local instance  = nil

-------------------------

--- Call jrnl command to extract entries, then store them in a table.
function journal:parse_entries()
  local cmd = "jrnl -to today --short -n 30"
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

--- Call jrnl command to get list of tags
function journal:parse_tags()
  local cmd = "jrnl --tags"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.tags = {}

    local tag_strings = core.split('\r\n', stdout)
    for i = 1, #tag_strings do
      local tokens = core.split('%s:', tag_strings[i])
      -- core.print_arr(tokens)
      local tagname = tokens[1]:sub(2)
      self.tags[#self.tags+1] = {tagname, tokens[2]}
    end

    self:emit_signal("ready::tags")
  end)
end

--- Retrieve entries tagged with a specific tag, then store them in table.
function journal:parse_entries_with_tag(tag)
  local cmd = "jrnl -to today --short -n 30 @" .. tag
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

    self.tagged[tag] = entries
    self:emit_signal("ready::entries", tag)
  end)
end

--------------

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

------------

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

--- Close dash, open term, start new jrnl entry
function journal:new_entry()
  local cmd = "kitty sh -c 'jrnl'"
  awful.spawn(cmd, {
    floating = true,
    geometry = {x=360, y=90, height=900, width=1200},
    placement = awful.placement.centered,
  })
end

function journal:reload()
  self.entries = {}
  self:parse_entries()
  self:emit_signal("ready::entries")
end

-------------------------

function journal:new()
  self.is_locked = true
  self.tagged = {}

  -- Enum for accessing entry fields
  self.date   = 1
  self.time   = 2
  self.title  = 3

  self:parse_entries()

  self:parse_tags()

  self:connect_signal("input_complete", function(_, input)
    self:try_unlock(input)
  end)

  self:connect_signal("entry_selected", function(_, index)
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
