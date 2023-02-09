
-- █▀▀ █▀█ █▄░█ █▀ █▀▀ █▀█ █░█ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- █▄▄ █▄█ █░▀█ ▄█ ██▄ █▀▄ ▀▄▀ █▀█ ░█░ █ █▄█ █░▀█ 

-- Toggles conservation mode on Lenovo laptops
-- Script path is ~/.config/awesome/utils/ctrl/conservation_toggle
-- The script requires root privileges; add it to /etc/sudoers

local awful   = require("awful")
local control = require("core.cozy.control")
local ui      = require("helpers.ui")
local gfs     = require("gears.filesystem")

local SCRIPT = 'sudo ' .. gfs.get_configuration_dir() .. "utils/ctrl/conservation_toggle"

local qa, nav_qa = ui.quick_action("Conservation Mode", "")

function nav_qa:release()
  awful.spawn.easy_async_with_shell(SCRIPT, function(stdout)
    stdout = string.gsub(stdout, "\r\n", "")
    ui.qa_notify("Conservation mode", stdout)
  end)
  control:toggle()
end

return function()
  return qa, nav_qa
end
