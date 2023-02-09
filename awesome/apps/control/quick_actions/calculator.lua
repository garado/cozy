
-- █▀▀ ▄▀█ █░░ █▀▀ █░█ █░░ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▄▄ █▀█ ░█░ █▄█ █▀▄ 

local awful   = require("awful")
local apps    = require("sysconf.apps")
local control = require("core.cozy.control")
local ui      = require("helpers.ui")

local qa, nav_qa = ui.quick_action("Calculator", "")

function nav_qa:release()
  awful.spawn(apps.default.terminal .. " -e python", {
    width  = 600,
    height = 400,
    floating  = true,
    ontop     = true,
    sticky    = true,
    tag       = mouse.screen.selected_tag,
    placement = awful.placement.bottom_right,
  })
  control:toggle()
end

return function()
  return qa, nav_qa
end
