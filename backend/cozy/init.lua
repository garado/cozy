
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- Manage state of popups.

local be = require("utils.backend")

return {
  dash = require(... .. ".dash"),
  kitty   = be.create_popup_manager({ name = "kitty"   }),
  control = be.create_popup_manager({ name = "control" }),
  notrofi = be.create_popup_manager({ name = "notrofi" }),
  scratchpad = require(... .. ".scratchpad"),
  themeswitch = require(... .. ".themeswitch"),
  bluetooth = require(... .. ".bluetooth"),
  systray_control = require(... .. ".systray_control")
}
