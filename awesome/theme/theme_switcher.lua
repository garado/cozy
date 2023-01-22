
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- This is for automagically matching your system color schemes to
-- your AwesomeWM color scheme. :-)

local beautiful = require("beautiful")
local awful  = require("awful")
local gears  = require("gears")
local gfs    = gears.filesystem

local config = require("config")
local theme_name = config.theme_name
local theme_style = config.theme_style
local theme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)
theme = theme.switcher

local HOME = os.getenv("HOME")
local CONFIG = HOME .. "/.config/"

-- █▄▀ █ ▀█▀ ▀█▀ █▄█ 
-- █░█ █ ░█░ ░█░ ░█░ 

local function kitty()
  local kitty_theme = theme.kitty
  local cmd = "kitty +kitten themes --reload-in=all " .. kitty_theme
  awful.spawn.with_shell(cmd)
end


-- █▄░█ █░█ █▀▀ █░█ ▄▀█ █▀▄ 
-- █░▀█ ▀▄▀ █▄▄ █▀█ █▀█ █▄▀ 

local function nvchad()
  local nvchad_theme = theme.nvchad

  -- Change nvchad config file.
  -- In my setup, the theme is in a file called theme.lua,
  -- and my chadrc contains the following:
  -- M.ui = {
  --  theme = require("custom.theme")
  --}
  local nvchad_theme_cfg = CONFIG .. "nvim/lua/custom/theme.lua"
  local change_cfg_cmd = "echo 'return \"" .. nvchad_theme .. "\"' > " .. nvchad_theme_cfg
  awful.spawn.with_shell(change_cfg_cmd)

  -- Script to reload theme for every running nvim instance
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


-- ▀█ ▄▀█ ▀█▀ █░█ █░█ █▀█ ▄▀█ 
-- █▄ █▀█ ░█░ █▀█ █▄█ █▀▄ █▀█ 

-- Change theme by symlinking zathurarc.
-- TODO: auto reload zathura theme
local function zathura()
  local ZATHURA_CONFIG = CONFIG .. "zathura/"
  local zathurarc = CONFIG .. "zathurarc"

  -- Create backup of user theme
  local backuprc = ZATHURA_CONFIG .. "zathurarc.user.bak"
  if not gfs.file_readable(backuprc) then
    awful.spawn.with_shell("cp " .. zathurarc .. " " .. backuprc)
  end

  -- Different zathura themes should all be in ~/.config/zathura
  local zathura_theme = ZATHURA_CONFIG .. theme.zathura
  local cmd = 'ln -sf ' .. zathura_theme  ..  ' ' .. zathurarc
  awful.spawn.with_shell(cmd)
end


-- █▀█ █▀█ █▀▀ █ 
-- █▀▄ █▄█ █▀░ █ 

-- Themes should be in ~/.config/rofi/themes
local function rofi()
  local ROFI_CFG = CONFIG .. 'rofi/'
  local rofi_theme = theme.rofi
  local rasi_path   = ROFI_CFG .. 'themes/' .. rofi_theme .. '.rasi'
  local colors_path = ROFI_CFG .. 'colors.rasi'

  local cmd = 'ln -sf ' .. rasi_path .. ' ' .. colors_path
  awful.spawn.with_shell(cmd)
end

return function()
  if theme.kitty   then kitty()   end
  if theme.nvchad  then nvchad()  end
  if theme.gtk     then gtk()     end
  if theme.zathura then zathura() end
  if theme.rofi    then rofi()    end
end

