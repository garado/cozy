
-- █▀█ █ ▀▄▀ █▀▀ █░░ ▄▀█ 
-- █▀▀ █ █░█ ██▄ █▄▄ █▀█ 

-- Pixela is a habit/effort tracker that you can use entirely through
-- API calls. It's pretty neat. https://pixe.la/

-- Cached habit data goes in the ~/.cache/awesome/pixela/* folder.
-- Each habit gets its own folder in there, i.e. ~/.cache/awesome/pixela/journal/
-- If a habit was completed on a particular day, there is a file titled 'YYYYMMDD' in the
-- habit folder: ~/.cache/awesome/pixela/journal/20230527
-- Thought this was the most efficient way to cache habit data as you can just use
-- gfs.file_readable to check habit statuses instead of waiting on an async call to
-- grep through the file.

-- Requires that you have the PIXELA_USER_NAME and PIXELA_USER_TOKEN env vars set.
-- TODO: Add option to specify this in config.

-- TODO: Handle trying to make API call if there's no internet
-- Local UI should update, but we should queue the API calls or something 
-- to try later when there is internet access

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local gfs     = require("gears.filesystem")

local credentials = require("cozyconf.pixela")

local USER_NAME  = credentials.name
local USER_TOKEN = credentials.token
local SECONDS_PER_DAY = 24 * 60 * 60
local DATE_FORMAT ="%Y%m%d"
local CACHE_DIR  = gfs.get_cache_dir() .. "pixela/"

local pixela = {}
local instance = nil

local function report_api_error(func, response)
  local err_msg = '"isSucces":false'
  if string.find(response, err_msg) then
    print("ERROR: "..func..": "..response)
  end
end

local function verify_cachefolder(id)
  local path = CACHE_DIR .. id
  if not gfs.dir_writable(path) then
    local cmd = 'touch ' .. path
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
end

--- @function verify_cachefile
-- @return String containing command to create the cache file if it doesn't already exist
local function verify_cachefile(id)
  -- First check pixela folder
  if not gfs.dir_writable(CACHE_DIR.."pixela") then
    gfs.make_directories(CACHE_DIR.."pixela")
  end

  -- Then check habit cache file in pixela/
  local filepath = CACHE_DIR..'pixela/'..id
  local cmd = 'touch "'..filepath..'" ; '
  if not gfs.file_readable(filepath) then
    print('Cachefile for '..id..' does not exist; creating one')
  end
  return (not gfs.file_readable(filepath) and cmd) or ""
end

--- @method read_habit_data
-- @brief Read cache file for a given habit and timestamp.
function pixela:read_habit_data(id, ts)
  return gfs.file_readable(CACHE_DIR..id..'/'..os.date(DATE_FORMAT, ts))
end

--- @method cache_habit_data
-- @param id Graph ID
-- @brief Make API call to fetch and then cache habit data for the last 7 days.
-- https://docs.pixe.la/entry/get-graph-pixels
-- NOTE: Pixela has this thing where GETs will fail 25% of the time if you're not a Patron.
-- Doesn't support retrying if it fails. (Unrelated: I am a Patron.)
function pixela:cache_habit_data(id)
  local s_date = os.date(DATE_FORMAT, os.time() - (SECONDS_PER_DAY * 7))
  local e_date = os.date(DATE_FORMAT)
  local url   = ' "https://pixe.la/v1/users/'..USER_NAME..'/graphs/'..id..
    '/pixels?from='..s_date..'&to='..e_date..'" '
  local token = " 'X-USER-TOKEN:"..USER_TOKEN.."' "

  local cmd = "curl -X GET"..url..'-H'..token
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    report_api_error('pixela:cache_habit_data', stdout)
  end)
end

--- @method update_habit
-- @param id (string) Graph ID
-- @param ts os.time timestamp of the day to modify
-- @param value (bool) True if habit should be marked completed, false otherwise.
-- @brief Mark habit as completed or not completed.
-- https://docs.pixe.la/entry/put-pixel
function pixela:update_habit(id, ts, value)
  local date = os.date(DATE_FORMAT, ts)
  local url   = " https://pixe.la/v1/users/"..USER_NAME.."/graphs/"..id.."/"..date
  local token = " 'X-USER-TOKEN:"..USER_TOKEN.."' "
  local qty   = value and 1 or 0
  local data  = " -d '{\"quantity\":\""..qty.."\"}' "

  local curl  = "curl -X PUT"..url.." -H "..token..data
  local touch = "touch " .. CACHE_DIR .. id .. '/' .. date
  local cmd   = curl .. ' ; ' .. touch
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    report_api_error('pixela:update_habit', stdout)
  end)
end

---------------------------------------------------------------------

function pixela:new()
  self:cache_habit_data("coding")
  self:cache_habit_data("gym")
  self:cache_habit_data("ledger")
  self:cache_habit_data("read")
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
