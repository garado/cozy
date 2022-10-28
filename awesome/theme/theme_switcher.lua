
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- This is for automagically matching your system color schemes to
-- your AwesomeWM color scheme. :-)

local awful = require("awful")
local gfs = require("gears.filesystem")
local config = require("config")
local theme_name = config.theme_name
local theme_style = config.theme_style
local theme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)
theme = theme.switcher

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

  -- Change nvchad config file.
  -- In my setup, the theme is in a file called theme.lua,
  -- and my chadrc contains the following:
  -- M.ui = {
  --  theme = require("custom.theme")
  --}
  local nvchad_theme_cfg = "~/.config/nvim/lua/custom/theme.lua"
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
local function zathura()
  -- Create backup of user theme.
  local backup = "~/.config/zathura/zathurarc.user.bak"
  if not gfs.file_readable(backup) then
    awful.spawn.with_shell("cp ~/.config/zathura/zathurarc " .. backup)
  end

  -- Different zathura themes should all be in ~/.config/zathura
  local zathura_theme = theme.zathura
  local cmd = "ln -sf ~/.config/zathura/" .. zathura_theme .. " ~/.config/zathura/zathurarc"
  awful.spawn.with_shell(cmd)

  -- To do: auto reload zathura theme
end

-- █▀█ █▀█ █▀▀ █ 
-- █▀▄ █▄█ █▀░ █ 
local function rofi()
  -- Different rofi themes should all be in ~/.config/rofi/cozy
  local rofi_theme = theme.rofi
  -- Todo: check for different image types
  local img_path = "~/.config/rofi/cozy/" .. rofi_theme .. ".jpg"
  local rasi_path = "~/.config/rofi/cozy/" .. rofi_theme .. ".rasi"

  local symlink_rasi = "ln -sf " .. rasi_path .. "~/.config/rofi/colors.rasi"
  local symlink_img = "ln -sf " .. img_path .. " ~/.config/rofi/image"
end

return function()
  if theme.kitty   then kitty()   end
  if theme.nvchad  then nvchad()  end
  if theme.gtk     then gtk()     end
  if theme.zathura then zathura() end
  -- if theme.rofi    then rofi()    end
end

