
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- This is for automagically matching your system color schemes to
-- your AwesomeWM color scheme. :-)

local awful = require("awful")
local gfs = require("gears.filesystem")
local user_vars = require("user_variables")
local theme_name = user_vars.theme_name
local theme_style = user_vars.theme_style
local theme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)

-- █▄▀ █ ▀█▀ ▀█▀ █▄█ 
-- █░█ █ ░█░ ░█░ ░█░ 
local function kitty()
  local kitty_theme = theme.kitty
  local cmd = "kitty +kitten themes --reload-in=all " .. kitty_theme
  awful.spawn(cmd)
end

-- █▄░█ █░█ █▀▀ █░█ ▄▀█ █▀▄ 
-- █░▀█ ▀▄▀ █▄▄ █▀█ █▀█ █▄▀ 
local function nvchad()
  local nvchad_theme = theme.nvchad

  -- change nvchad config file
  local nvchad_theme_cfg = "/home/alexis/.config/nvim/lua/custom/theme.lua"
  local change_cfg_cmd = "echo 'return \"" .. nvchad_theme .. "\"' > " .. nvchad_theme_cfg
  awful.spawn.with_shell(change_cfg_cmd)

  -- reload theme for every running nvchad instance
  local cfg = gfs.get_configuration_dir()
  local nvchad_reload = "python " .. cfg .. "utils/neovim_reload.py"
  local reload_theme_cmd = nvchad_reload .. " " .. nvchad_theme
  awful.spawn.with_shell(reload_theme_cmd)
end

-- █▀▀ ▀█▀ █▄▀ 
-- █▄█ ░█░ █░█ 
-- Not really working, idk why
local function gtk()
  local gtk_theme = theme.gtk
  local cmd = "gsettings set org.gnome.desktop.interface gtk-theme '" .. gtk_theme .. "'"
  awful.spawn.with_shell(cmd)
end

return function()
  if theme.kitty  then kitty()  end
  if theme.nvchad then nvchad() end
  if theme.gtk    then gtk()    end
end
