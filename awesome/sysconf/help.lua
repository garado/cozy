
-- █░█ █▀▀ █░░ █▀█ 
-- █▀█ ██▄ █▄▄ █▀▀ 

-- Program-specific hotkeys for the popup help menu

local hotkeys_popup = require("awful.hotkeys_popup").widget
local mod   = "Mod4"
local alt   = "Mod1"
local ctrl  = "Control"
local shift = "Shift"

local fire_rule = { class = { "firefox", "Firefox" } }
for group_name, group_data in pairs({
  ["Firefox: tabs"] = { color = "#009F00", rule_any = fire_rule }
}) do
  hotkeys_popup.add_group_rules(group_name, group_data)
end

local firefox_keys = {
  ["Firefox"] = {
    {
      modifiers = { ctrl, shift },
      keys = {
        ["t"] = "reopen tab",
        ["b"] = "toggle personal toolbar",
      }
    },
    {
      modifiers = { alt },
      keys = {
        ["left"]  = "backwards in history",
        ["right"] = "forwards in history",
      },
    }
  }
}

hotkeys_popup.add_hotkeys(firefox_keys)
