
-- █▀█ █ ▀▄▀ █▀▀ █░░ ▄▀█ 
-- █▀▀ █ █░█ ██▄ █▄▄ █▀█ 

local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")
local config = require("config")
local gfs = require("gears.filesystem")
local naughty = require("naughty")

local pixela = { }
local instance = nil

local pi_path = "~/go/bin/pi "

---------------------------------------------------------------------

--- Refresh cache contents by overwriting cache with Pixela API output
function pixela:sync_cache_data()
  print("Core:Pixela: Syncing cache data...")
  local set_pixela_user, set_pixela_token
  if config.pixela then
    set_pixela_user   = "export PIXELA_USER_NAME=" .. config.pixela.user
    set_pixela_token  = "export PIXELA_USER_TOKEN=" .. config.pixela.token
  end

  for id, _ in pairs(config.habit) do
    local path = gfs.get_cache_dir() .. "pixela/" .. id
    local cmd = set_pixela_user .. " ; " .. set_pixela_token .. " ; "
    cmd = cmd .. "pi graphs pixels -g " .. id .. " > " .. path
    awful.spawn.with_shell(cmd)
  end
end

--- For every habit specified in the user's config file, grab the last
-- 4 days of habit data from the cache file in ~/.cache/awesome/pixela.
-- Store the data directly within config.habit table from user config file
-- because why bother making another table with the same info.
function pixela:parse_cache_data()
  -- Get graph ids from user config file
  local habits = config.habit

  for graph_id, _ in pairs(habits) do
    local file = gfs.get_cache_dir() .. "pixela/" .. graph_id
    local cmd = "cat " .. file

    awful.spawn.easy_async_with_shell(cmd, function(stdout)

      -- Check cache for the status of the last 4 days
      -- Append status to completion table (4 days ago == 1st entry in table)
      local completion = {}
      for j = 3, 0, -1 do
        local current_time = os.time()
        local j_days_ago = current_time - (60 * 60 * 24 * j) -- days ago in seconds
        local date = tostring(os.date("%Y%m%d", j_days_ago))

        if string.find(stdout, date) ~= nil then
          completion[#completion+1] = true
        else
          completion[#completion+1] = false
        end
      end

      config.habit[graph_id]["completion"] = completion
      self:emit_signal("update::habits", graph_id)

    end)

  end
end -- end pixela:parse_cache_data

--- Call Pixela API command to update habit values
function pixela:update_pixela(graph_id, date, qty)
  local set_pixela_user, set_pixela_token
  if config.pixela then
    set_pixela_user   = "export PIXELA_USER_NAME=" .. config.pixela.user
    set_pixela_token  = "export PIXELA_USER_TOKEN=" .. config.pixela.token
  end

  local _qty = qty and "1" or "0"
  local graph_id_cmd = " -g " .. graph_id
  local date_cmd     = " -d " .. date
  local qty_cmd      = " -q " .. _qty
  local pi_cmd = pi_path .. "pixel update" .. graph_id_cmd .. date_cmd .. qty_cmd
  local cmd = set_pixela_user .. " ; " .. set_pixela_token .. " ; " .. pi_cmd
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    -- Handle command errors
    if stderr ~= "" then
      self:report_pixela_error(stderr)
      return
    end

    -- Pixela api returns api request status - check for success
    local state = qty and "complete" or "not complete"
    if string.find(stdout, "Success") then
      naughty.notification {
        app_name = "System notification",
        title = "Pixela API",
        message = "Successfully set " .. graph_id .. " as " .. state,
      }
    else
      naughty.notification {
        app_name = "System notification",
        title = "Pixela API",
        message = "Setting " .. graph_id .. " as " .. state .. " failed",
        timeout = 0,
      }
    end
  end)
end

--- Update cache for a graph by adding or removing text to the cache file
function pixela:update_cache(graph_id, date, set_as_complete)
  local file = gfs.get_cache_dir() .. "pixela/" .. graph_id
  local cmd
  if set_as_complete then
    -- Append date to file
    cmd = "echo '" .. date .. "' >> " .. file
  else
    -- Remove date from file
    cmd = "sed -e s/" .. date .. "//g -i " .. file
  end
  awful.spawn.with_shell(cmd)
end

---------------------------------------------------------------------

--- Return the completion status of a habit
function pixela:get_habit_data(graph_id, days_ago)
  return config.habits[graph_id]["completion"][days_ago]
end

function pixela:report_pixela_error(stderr)
  if string.find(stderr, "command not found") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela 'pi' command not found",
      timeout = 0,
    }
  elseif string.find(stderr, "Please specify username") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela username not found - set this in config",
      timeout = 0,
    }
  elseif string.find(stderr, "Please specify password") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela password not found - set this in config",
      timeout = 0,
    }
  end
end

---------------------------------------------------------------------

function pixela:new()
  self:parse_cache_data()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, pixela, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
