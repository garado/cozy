
-- █▀▀ █▀█ █▀▄▀█ █▀▄▀█ ▄▀█ █▄░█ █▀▄ █▀ 
-- █▄▄ █▄█ █░▀░█ █░▀░█ █▀█ █░▀█ █▄▀ ▄█ 

-- Keybindings for agenda tab.

local agenda  = require("core.system.cal")

local NORMAL = 1
local MODIFY = 2

local modes   = { "normal", "modify" }
local curmode = NORMAL

local commands = {
  ["normal"] = {
    ["R"] = "refresh",
    ["a"] = "add_title",
    ["x"] = "delete",
    ["m"] = "modify",
    ["o"] = "open",
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
  if curmode == NORMAL then
    agenda:emit_signal("prompt::clear")
  end
end

--- Determines the type of input to request based on the key input and the current mode.
-- The request_get_info signal is caught in upcoming.lua where it will pass event title/event date to core.
-- @param key   The key inputted by the user.
local function request_input(key)
  local mode = modes[curmode]
  local cmd = commands[mode][key]

  if not cmd then return end
  if key == 'm' then modeswitch(MODIFY) end

  agenda:emit_signal("input::request_get_info", cmd)
end

-- Switch back to normal mode on input completion
agenda:connect_signal("input::complete", function()
  modeswitch(NORMAL)
end)

return {
  ["Escape"] = function() modeswitch(NORMAL) end,
  ["m"]   = function() request_input('m') end,
  ["R"]   = function() request_input('R') end,
  ["a"]   = function() request_input('a') end,
  ["t"]   = function() request_input('t') end,
  ["l"]   = function() request_input('l') end,
  ["o"]   = function() request_input('o') end,
  ["w"]   = function() request_input('w') end,
  ["x"]   = function() request_input('x') end,
  ["d"]   = function() request_input('d') end,
}
