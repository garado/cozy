
-- █▄░█ █ █▀▀ █░█ ▀█▀ █▀ █░█ █ █▀▀ ▀█▀ 
-- █░▀█ █ █▄█ █▀█ ░█░ ▄█ █▀█ █ █▀░ ░█░ 

local awful   = require("awful")
local ui      = require("helpers.ui")
local config  = require("cozyconf")

local qa, nav_qa = ui.quick_action("Nightshift", "")

function nav_qa:release()
  local lat  = config.control.nightshift.lat
  local long = config.control.nightshift.long
  local cmd  = "pidof redshift"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local message
    local redshift_active = stdout ~= ""
    if redshift_active then
      awful.spawn.with_shell("pkill redshift")
      message = "Disabled"
    else
      local coords = lat .. ":" .. long
      awful.spawn.with_shell("redshift -l " .. coords)
      message = "Enabled"
    end
    ui.qa_notify("Nightshift", message)
  end)
end

return function()
  return qa, nav_qa
end
