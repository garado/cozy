
-- █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀ 
-- █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█ 

local strutil = require("utils.string")
local awful = require("awful")

local kb = {}
local client_keybinds = {}

local MODS = {
  ["Shift"]   = "Shift",
  ["Alt"]     = "Mod1",
  ["Ctrl"]    = "Control",
  ["Control"] = "Control",
  ["Super"]   = "Mod4",
  ["Mod"]     = "Mod4",
  ["Mod4"]    = "Mod4",
}

--- @method add_keygroup
function kb.add_keygroup(name, keys)
  local kg = {}
  for i, key in ipairs(keys) do kg[i] = { key, i } end
  awful.key.keygroups[name] = kg
end

--- @method bindparse
-- @param k
-- @return mods
-- @return keybind
-- @return keygroup
local function bindparse(keystr)
  local mods = {}
  local keybind = ""
  local kg

  local tokens = strutil.split(keystr, "+")
  for _, key in ipairs(tokens) do
    if key:sub(1,1) == "[" then
      -- Keygroup specified
      kg = key:gsub("[%[%]]", "")
    elseif MODS[key] then
      -- Modifier
      mods[#mods+1] = MODS[key]
    else
      -- Normal key
      keybind = keybind .. key
    end
  end

  return mods, keybind, kg
end

-- KEYBINDS ----------------------

local function _bind(keys, func, desc, group)
  local bind
  local m, k, kg = bindparse(keys)
  if not kg then
    bind = awful.key{
      key = k,
      modifiers = m,
      description = desc or nil,
      group = group or nil,
      on_press = func,
    }
  else
    bind = awful.key{
      modifiers = m,
      keygroup = kg or nil,
      description = desc or nil,
      group = group or nil,
      on_press = func,
    }
  end
  return bind
end

--- @method global_keybind
-- @brief add a global keybind
function kb.global_keybind(...)
  awful.keyboard.append_global_keybindings({ _bind(...) })
end

--- @method client_keybind
-- @brief add a client keybind
function kb.client_keybind(...)
  client_keybinds[#client_keybinds+1] = _bind(...)
end

-- MOUSEBINDS ----------------------

function kb.client_mousebind(...)
end

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings(client_keybinds)
end)

return kb
