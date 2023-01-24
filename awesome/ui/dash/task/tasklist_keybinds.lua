
-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀ 
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█ 

-- Custom keys for managing tasks in the tasklist widget.
-- Handles executing Taskwarrior commands.

local task    = require("core.system.task")
-- local awful   = require("awful")
-- local core    = require("helpers.core")
-- local time    = require("core.system.time")

local NORMAL = 1
local MODIFY = 2

local modes   = { "normal", "modify" }
local curmode = NORMAL

local keybinds = {
  normal = {
    ["A"] = "annotate",
    ["a"] = "add",
    ["s"] = "start",
    ["u"] = "undo",
    ["m"] = "modify",
    ["o"] = "open",
    ["d"] = "done",
    ["x"] = "delete",
    ["p"] = "new_proj",
    ["t"] = "new_tag",
    ["n"] = "next",
    ["H"] = "help",
    ["R"] = "reload",
    ["/"] = "search",
  },
  modify = {
    ["d"] = "mod_due",
    ["p"] = "mod_proj",
    ["t"] = "mod_tag",
    ["n"] = "mod_name",
    ["w"] = "mod_wait",
    ["L"] = "mod_link",
    ["Escape"] = "mod_clear",
  }
}

local function modeswitch(mode)
  curmode = mode
end

--- Determines the type of input to request based on the key input and the current mode.
-- The request is caught in prompt.lua.
-- @param key   The key inputted by the user.
local function request_input(key)
  local mode = modes[curmode]
  local cmd  = keybinds[mode][key]

  if not cmd then return end
  if key == 'm' then modeswitch(MODIFY) end
  if key == 'Escape' then modeswitch(NORMAL) end

  if key == 'o' then
    if not task.focused_task["link"] then return end
  end

  task:emit_signal("input::request", cmd)

  return true -- tell navigator that command was successful
end

task:connect_signal("input::complete", function()
  modeswitch(NORMAL)
end)

task:connect_signal("input::cancelled", function()
  modeswitch(NORMAL)
end)

return {
  ["m"] = function() request_input("m") end,
  ["a"] = function() request_input("a") end,
  ["w"] = function() request_input("w") end,
  ["A"] = function() request_input("A") end,
  ["L"] = function() request_input("L") end,
  ["x"] = function() request_input("x") end,
  ["s"] = function() request_input("s") end,
  ["o"] = function() request_input("o") end,
  -- ["u"] = function() request_input("u") end, -- currently broken bc of taskwarrior hook
  ["d"] = function() request_input("d") end,
  ["p"] = function() request_input("p") end,
  ["t"] = function() request_input("t") end,
  ["n"] = function() request_input("n") end,
  ["R"] = function() request_input("R") end,
  ["/"] = function() request_input("/") end,
  ["Escape"] = function() request_input("Escape") end,
}
