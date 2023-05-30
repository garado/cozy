
-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀ 
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█ 

-- Keybinds for editing tasks.

local task = require("backend.system.task")

local curmode = "normal"
task:connect_signal("input::complete",  function() curmode = "normal" end)
task:connect_signal("input::cancelled", function() curmode = "normal" end)

-- Define signal names for all valid keys.
local keybinds = {
  normal = {
    ["a"] = "add",
    ["A"] = "annotation",
    ["m"] = "modify",
    ["d"] = "done",
    ["x"] = "delete",
    ["r"] = "refresh",
    ["/"] = "search",
  },
  modify = {
    ["d"] = "mod_due",
    ["p"] = "mod_project",
    ["t"] = "mod_tag",
    ["n"] = "mod_name",
    ["Escape"] = "mod_clear",
  }
}

-- Emit signal name.
-- This is caught in prompt.lua
local function request_input(key)
  print('Requesting input for "'..key..'". Current mode is '..curmode)

  -- Refreshing should immediately execute and take no input
  if key == "r" then
    task:emit_signal("refresh")
    return
  end

  local cmd  = keybinds[curmode][key]

  print('Cmd is '..(cmd or "n/a"))

  if not cmd then return end
  if key == 'm' then curmode = "modify" end
  if key == 'Escape' then curmode = "normal" end

  task:emit_signal("input::request", cmd)
end

-- Now generate keybinds for the navigator.
local nav_keybinds = {}

for key in pairs(keybinds.normal) do
  nav_keybinds[key] = function() request_input(key) end
end

for key in pairs(keybinds.modify) do
  nav_keybinds[key] = function() request_input(key) end
end

return nav_keybinds
