
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █ █▄░█ ▀█▀ █▀▀ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    █ █░▀█ ░█░ ██▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ 

-- This is for automagically matching your system color schemes to
-- your AwesomeWM color scheme. :-)

local awful  = require("awful")
local gears  = require("gears")
local gfs    = gears.filesystem
local config = require("config")

local theme_name  = config.theme_name
local theme_style = config.theme_style
local theme_path  = "theme.colorschemes." .. theme_name .. "." .. theme_style
local theme = require(theme_path).switcher

local HOME   = os.getenv("HOME")
local CONFIG = HOME .. "/.config/"

-- █▄▀ █ ▀█▀ ▀█▀ █▄█ 
-- █░█ █ ░█░ ░█░ ░█░ 

local function kitty()
  local kitty_theme = theme.kitty
  local cmd = "kitty +kitten themes --reload-in=all " .. kitty_theme
  awful.spawn.easy_async_with_shell(cmd, function() end)
end


-- █▄░█ █░█ █▀▀ █░█ ▄▀█ █▀▄ 
-- █░▀█ ▀▄▀ █▄▄ █▀█ █▀█ █▄▀ 

local function nvchad()
  local nvchad_theme = theme.nvchad

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
  awful.spawn.easy_async_with_shell(reload_theme_cmd, function() end)
end


-- █▀▀ ▀█▀ █▄▀ 
-- █▄█ ░█░ █░█ 

-- Not really working, idk why
local function gtk()
  local gtk_theme = theme.gtk
  local cmd = "gsettings set org.gnome.desktop.interface gtk-theme '" .. gtk_theme .. "'"
  awful.spawn.easy_async_with_shell(cmd, function() end)
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
  awful.spawn.easy_async_with_shell(cmd, function() end)
end


-- █▀█ █▀█ █▀▀ █ 
-- █▀▄ █▄█ █▀░ █ 

-- Themes are in ~/.config/rofi/themes
local function rofi()
  local ROFI_CFG = CONFIG .. 'rofi/'
  local rofi_theme = theme.rofi
  local rasi_path   = ROFI_CFG .. 'themes/' .. rofi_theme .. '.rasi'
  local colors_path = ROFI_CFG .. 'colors.rasi'

  local cmd = 'ln -sf ' .. rasi_path .. ' ' .. colors_path
  awful.spawn.easy_async_with_shell(cmd, function() end)
end


-- █▀▀ █ █▀█ █▀▀ █▀▀ █▀█ ▀▄▀ 
-- █▀░ █ █▀▄ ██▄ █▀░ █▄█ █░█ 

-- Uses custom Firefox css and startpage
-- https://github.com/andreasgrafen/cascade/
local function firefox()
  local css = "~/.mozilla/firefox/*default-release/chrome/includes/cascade-colours.css"
  local custom_css = "~/Github/cozy/misc/firefox/cascade/" .. theme.firefox .. ".css"
  local cmd = "ln -sf " .. custom_css .. " " .. css
  awful.spawn.easy_async_with_shell(cmd, function() end)
end

local function startpage()
  local gif_overwrite = "~/Github/cozy/misc/firefox/startpage/art.gif"
  local css_overwrite = "~/Github/cozy/misc/firefox/startpage/colors.css"
  local new_gif = "~/Github/cozy/misc/firefox/startpage/assets/" .. theme.start .. ".gif"
  local new_css = "~/Github/cozy/misc/firefox/startpage/themes/" .. theme.start .. ".css"
  local cmd_1 = "ln -sf " .. new_gif .. " " .. gif_overwrite
  local cmd_2 = "ln -sf " .. new_css .. " " .. css_overwrite
  local cmd = cmd_1 .. " ; " .. cmd_2
  awful.spawn.easy_async_with_shell(cmd, function() end)
end

return function()
  if theme.kitty   then kitty()     end
  if theme.nvchad  then nvchad()    end
  if theme.gtk     then gtk()       end
  if theme.zathura then zathura()   end
  if theme.rofi    then rofi()      end
  if theme.firefox then firefox()   end
  if theme.start   then startpage() end
end
