
-- █ █▄░█ ▀█▀ █▀▀ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █ █░▀█ ░█░ ██▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

-- Functions for automagically matching your system colorscheme
-- to Cozy's colorscheme. :-)

local awful = require("awful")
local gears = require("gears")
local gfs   = require("gears.filesystem")
local conf  = require("cozyconf.ui")

local theme_name = conf.theme_name
local theme_style = conf.theme_style
local theme = require("theme.colorschemes." .. theme_name .. '.' .. theme_style)

local HOME = os.getenv("HOME")
local CONFIG = HOME .. "/.config/"

print('Integrating theme ' .. theme_name .. ' ' .. theme_style)

-- █▄▀ █ ▀█▀ ▀█▀ █▄█ 
-- █░█ █ ░█░ ░█░ ░█░ 

local function kitty()
  local cmd = "kitty +kitten themes --reload-in=all " .. theme.integrations.kitty
  awful.spawn.easy_async_with_shell(cmd, function() end)
end

-- █▄░█ █░█ █ █▀▄▀█ 
-- █░▀█ ▀▄▀ █ █░▀░█ 

local function nvim()
  -- Update nvim config file
  local nvim_theme_cfg = CONFIG .. 'nvim/theme.vim'
  local change_cfg_cmd = "echo 'colorscheme " .. theme.integrations.nvim .. "' > " .. nvim_theme_cfg
  awful.spawn.easy_async_with_shell(change_cfg_cmd, function()
    -- Then run script to reload config file for every running nvim instance
    local awcfg = gfs.get_configuration_dir()
    local nvchad_reload = "python " .. awcfg .. "utils/scripts/nvim-reload.py"
    local reload_theme_cmd = nvchad_reload .. " " .. theme.integrations.nvim
    awful.spawn.easy_async_with_shell(reload_theme_cmd, function() end)
  end)
end

if theme.integrations.kitty then kitty() end
if theme.integrations.nvim  then nvim() end
