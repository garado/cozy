
-- █▀ █░█ ▄▀█ █▀█ █▀▀ █▀▄ 
-- ▄█ █▀█ █▀█ █▀▄ ██▄ █▄▀ 

-- A library of functions that are shared across different
-- ui components

local awful = require("awful")

local _shared = {}

-- When opening a popup, close all other ones
function _shared.close_other_popups(popup_name)
  local popup_list = {
    "dash",
    "control_center",
    "theme_switcher",
    "app_launcher",
  }

  for i = 1, #popup_list do
    if popup_list[i] ~= popup_name then
      local signal = popup_list[i] .. "::close"
      awesome.emit_signal(signal)
    end
  end
end

return _shared
