
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

local function kitty()
  -- This should be set in <colorscheme>.lua
  local kitty_theme = theme.kitty

  -- The command to change the application's color scheme
  local cmd = "kitty +kitten themes --reload-in=all " .. kitty_theme
  awful.spawn(cmd)
end

local function nvim()
  local nvim_theme = theme.nvim

  -- change nvchad config file
  local nvim_theme_cfg = "/home/alexis/.config/nvim/lua/custom/theme.lua"
  local change_cfg_cmd = "echo 'return \"" .. nvim_theme .. "\"' > " .. nvim_theme_cfg
  awful.spawn.with_shell(change_cfg_cmd)

  -- reload theme for every running nvim instance
  local cfg = gfs.get_configuration_dir()
  local nvim_reload = "python " .. cfg .. "utils/neovim_reload.py"
  local reload_theme_cmd = nvim_reload .. " " .. nvim_theme
  awful.spawn.with_shell(reload_theme_cmd)
end

local function gtk()
  local gtk_theme = theme.gtk
  local cmd = "gsettings set org.gnome.desktop.interface gtk-theme '" .. gtk_theme .. "'"
  awful.spawn.with_shell(cmd)
end

return function()
  if theme.kitty  then kitty()  end
  if theme.nvim   then nvim()   end
  if theme.gtk    then gtk()    end
end

