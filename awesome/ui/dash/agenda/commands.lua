
-- █▀▀ █▀█ █▀▄▀█ █▀▄▀█ ▄▀█ █▄░█ █▀▄ █▀ 
-- █▄▄ █▄█ █░▀░█ █░▀░█ █▀█ █░▀█ █▄▀ ▄█ 

-- Keybindings for agenda tab.
-- (also attempting to rewrite the task tab prompt/keybinds in a cleaner way)

local agenda  = require("core.system.cal")

----- 

local modes   = { "normal", "modify" }
local curmode = 1

local commands = {
  ["normal"] = {
    ["R"] = "refresh",
    ["a"] = "add_title",
    ["x"] = "delete",
    ["m"] = "modify",
    ["o"] = "open", -- copy location
  },
  ["modify"] = {
    ["t"]   = "mod_title",
    ["l"]   = "mod_loc",
    ["w"]   = "mod_when",
    ["d"]   = "mod_dur",
    ["Esc"] = "mod_clear",
  }
}

-----

local function modeswitch(modenum)
  curmode = modenum
end

--- Determines the type of input to request based on the key input and the current mode.
-- The request_get_info signal is caught in upcoming.lua where it will pass event title/event date to core.
-- @param key   The key inputted by the user.
local function request_input(key)
  local mode = modes[curmode]
  local cmd = commands[mode][key]

  if not cmd then return end
  if key == "m" then modeswitch(2) end

  agenda:emit_signal("input::request_get_info", cmd)
end

-- Switch back to normal mode on input completion
agenda:connect_signal("input::complete", function()
  modeswitch(1)
end)

return {
  ["Esc"] = { f = function() modeswitch(1)      end },
  ["m"]   = { f = function() request_input('m') end },
  ["R"]   = { f = function() request_input('R') end },
  ["a"]   = { f = function() request_input('a') end },
  ["t"]   = { f = function() request_input('t') end },
  ["l"]   = { f = function() request_input('l') end },
  ["o"]   = { f = function() request_input('o') end },
  ["w"]   = { f = function() request_input('w') end },
  ["x"]   = { f = function() request_input('x') end },
  ["d"]   = { f = function() request_input('d') end },
}
