
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
    ["a"] = "add",
    ["d"] = "delete",
    ["m"] = "modify",
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
  ["Esc"] = {["function"] = modeswitch, ["args"] = 1},
  ["m"]   = {["function"] = request_input, ["args"] = "m"},
  ["R"]   = {["function"] = request_input, ["args"] = "R"},
  ["a"]   = {["function"] = request_input, ["args"] = "a"},
  ["t"]   = {["function"] = request_input, ["args"] = "t"},
  ["l"]   = {["function"] = request_input, ["args"] = "l"},
  ["w"]   = {["function"] = request_input, ["args"] = "w"},
  ["d"]   = {["function"] = request_input, ["args"] = "d"},
  -- 
  ["s"]   = {["function"] = request_input, ["args"] = "s"},
  ["e"]   = {["function"] = request_input, ["args"] = "e"},
  ["S"]   = {["function"] = request_input, ["args"] = "S"},
  ["E"]   = {["function"] = request_input, ["args"] = "E"},
}
