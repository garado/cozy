
-- █▀█ █ ▀▄▀ █▀▀ █░░ ▄▀█ 
-- █▀▀ █ █░█ ██▄ █▄▄ █▀█ 

-- Pixela is a habit/effort tracker that you can use entirely through
-- API calls. It's pretty neat. https://pixe.la/

local json    = require("modules.json")
local habits  = require("cozyconf").habits
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

--- @method get_all_graph_pixels
-- @brief Refresh cache for all graphs listed in config.
function pixela:get_all_graph_pixels()
  for i = 1, #habits do
    self:get_graph_pixels(habits[i])
  end
end

--- @method get_graph_pixels
-- @param id Graph ID
-- @brief Get and cache graph pixel data.
function pixela:get_graph_pixels(id)
  local cfile = CACHE_DIR .. id
  local url = "https://pixe.la/v1/users/"..USER_NAME.."/graphs/"..id.."/pixels"
  local cmd = "curl -X GET "..url..HEADER.." > "..cfile
  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("cached::"..id)
  end)
end

--- @method put_habit_status
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

  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    if stdout:find('"isSuccess":true') then
      self:get_graph_pixels(id) -- Update local cache

      require("naughty").notification {
        app_name = "Cozy",
        title = "Pixela",
        message = "API call successful.",
      }
    else
      local msg = stderr:find("Could not resolve host") and "Could not resolve host" or json.decode(stdout).message
      require("naughty").notification {
        app_name = "Cozy",
        title = "Pixela: API call unsuccessful",
        message = msg,
      }
    end
  end)
end

--- @method read_graph_pixels
-- @param id Graph ID
-- @brief Read cached graph pixel data. If data isn't cached, fetch it.
function pixela:read_graph_pixels(id)
  local cfile = CACHE_DIR .. id

  if not gfs.file_readable(cfile) then
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

  -- 'cached::id' signal is emitted whenever the cache is updated with data fetched
  -- from Pixela. When this signal is received, read the cache file so that the UI
  -- can update.
  for i = 1, #habits do
    self:connect_signal("cached::"..habits[i], function()
      self:read_graph_pixels(habits[i])
    end)
  end
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
