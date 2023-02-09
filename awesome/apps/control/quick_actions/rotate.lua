
-- █▀█ █▀█ ▀█▀ ▄▀█ ▀█▀ █▀▀ 
-- █▀▄ █▄█ ░█░ █▀█ ░█░ ██▄ 

local awful   = require("awful")
local apps    = require("sysconf.apps")
local control = require("core.cozy.control")
local ui      = require("helpers.ui")
local gfs     = require("gears.filesystem")

local SCRIPTS = gfs.get_configuration_dir() .. "utils/ctrl/"

local qa, nav_qa = ui.quick_action("Rotate", "")

function nav_qa:release()
  -- Gets current screen orientation
  -- Works on my machine ¯\_(ツ)_/¯
  local cmd =  "xrandr --query | head -n 2 | tail -n 1 | cut -d ' ' -f 5"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local orientation
    if stdout:find("normal") then
      orientation = "left"
    else
      orientation = "normal"
    end
    local rotate_cmd = SCRIPTS .. "rotate_screen " .. orientation
    awful.spawn(rotate_cmd)
  end)
end

return function()
  return qa, nav_qa
end
