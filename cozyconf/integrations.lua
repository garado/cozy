
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █ █▄░█ ▀█▀ █▀▀ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    █ █░▀█ ░█░ ██▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ 

-- This is where you make Cozy's theme switcher affect other applications.

-- NOTE: When you're done writing your custom integrations, don't
-- forget to set `theme_integration = true` in the config file.

local gfs   = require("gears.filesystem")
local awful = require("awful")

local HOME    = os.getenv("HOME")
local CONFIG  = HOME .. "/.config/"
local SCRIPTS = gfs.get_configuration_dir() .. "utils/scripts/"

return {
  kitty = function(args)
    local cmd = "kitty +kitten themes --reload-in=all " .. args
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  nvim = function(args)
    -- Find the line containing the theme and update it
    local theme_path = CONFIG .. "nvim/lua/custom/chadrc.lua"
    local cmd = "sed -i 's/theme =.*/theme = \"" ..args.."\",'/ " .. theme_path
    awful.spawn.easy_async_with_shell(cmd, function()
      -- Send "ForceReloadNvchadTheme" command to every running nvim instance
      -- (it's a custom command - not built into nvchad)
      cmd = "python " .. SCRIPTS .. "nvim-reload.py ForceReloadNvchadTheme"
      awful.spawn.easy_async_with_shell(cmd, function() end)
    end)
  end
}
