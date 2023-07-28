
-- █▀█ █ ▀▄▀ █▀▀ █░░ ▄▀█ 
-- █▀▀ █ █░█ ██▄ █▄▄ █▀█ 

-- Pixela is a habit/effort tracker that you can use entirely through
-- API calls. It's pretty neat. https://pixe.la/

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local gfs     = require("gears.filesystem")

local credentials = require("cozyconf.pixela")
local USER_NAME  = credentials.name
local USER_TOKEN = credentials.token
local HEADER = " -H 'X-USER-TOKEN:"..USER_TOKEN.."' "
local CACHE_DIR  = gfs.get_cache_dir() .. "pixela/"

local pixela = {}
local instance = nil

---------------------------------------------------------------------

function pixela:get_graph_def(id)
  local url = "https://pixe.la/v1/users/"..USER_NAME.."/graphs/"..id.."/graph-def"
  local cmd = "curl -X GET "..url..HEADER
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    print('GET GRAPH DEF: '..stdout)
  end)
end

--- @method get_graph_pixels
-- @param id Graph ID
-- @brief Get and cache graph pixel data.
function pixela:get_graph_pixels(id)
  local cfile = CACHE_DIR .. id
  local url = "https://pixe.la/v1/users/"..USER_NAME.."/graphs/"..id.."/pixels"
  local cmd = "curl -X GET "..url..HEADER.." > "..cfile
  print(cmd)
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    print(id..": "..stdout)
    local signal = "cached::" .. id
    self:emit_signal(signal)
  end)
end

--- @method set_habit_status
-- @param id    pixela graph ID
-- @param ts    os.time timestamp for the day in question
-- @param state true or false
function pixela:put_habit_status(id, ts, state)
  local date = os.date(self.date_format, ts)
  local url  = "https://pixe.la/v1/users/"..USER_NAME.."/graphs/"..id.."/"..date

  local cmd
  if state then
    cmd = "curl -X PUT "..url..HEADER.." -d '{\"quantity\":\"1\"}' "
  else
    cmd = "curl -X DELETE "..url..HEADER
  end

  awful.spawn.easy_async_with_shell(cmd, function()
    -- Update local cache
    self:get_graph_pixels(id)
  end)
end

--- @method read_graph_pixels
-- @param id Graph ID
-- @brief Read cached graph pixel data. If data isn't cached, fetch it.
function pixela:read_graph_pixels(id)
  local cfile = CACHE_DIR .. id

  if not gfs.file_readable(cfile) then
    local on_cache
    function on_cache()
      local cmd = "cat " .. cfile
      awful.spawn.easy_async_with_shell(cmd, function(stdout)
        local signal = "ready::" .. id
        self:emit_signal(signal, stdout)
        self:disconnect_signal("cached::"..id, on_cache)
      end)
    end

    self:connect_signal("cached::"..id, on_cache)
    self:get_graph_pixels(id)
  else
    local cmd = "cat " .. cfile
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local signal = "ready::" .. id
      self:emit_signal(signal, stdout)
    end)
  end
end

---------------------------------------------------------------------

function pixela:new()
  self.date_format = "%Y%m%d"
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, pixela, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
