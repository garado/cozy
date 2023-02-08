
-- █▀█ █░█ █▀ █░█ █▀█ █░█ █▀▀ █▀█ 
-- █▀▀ █▄█ ▄█ █▀█ █▄█ ▀▄▀ ██▄ █▀▄ 

-- Handles sending Pushover notifications

local awful  = require("awful")
local config = require("cozyconf")

local pushover = {}

local URL = 'https://api.pushover.net/1/messages.json'
local USER_KEY  = ' --form-string "user=' .. config.pushover.user_key  .. '" '
local API_TOKEN = ' --form-string "token=' .. config.pushover.api_token .. '" '

function pushover:post(title, msg)
  local _msg   = ' --form-string "message=' .. msg .. '" '
  local _title = ' --form-string "title=' .. title ..'" '
  local cmd = "curl -s " .. USER_KEY .. API_TOKEN .. _msg .. _title .. URL
  awful.spawn.easy_async_with_shell(cmd, function() end)
end

return pushover
