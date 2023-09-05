
-- █ █▄░█ ▀█▀ █▀▀ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █ █░▀█ ░█░ ██▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

-- Functions for automagically matching your system colorscheme
-- to Cozy's colorscheme. :-)

-- NOTE: When you're done writing your custom integrations, don't
-- forget to set `theme_integration = true` in the config file.

local awful = require("awful")
local gfs   = require("gears.filesystem")

local HOME = os.getenv("HOME")
local CONFIG = HOME .. "/.config/"

return function(name, style)
  local theme = require("theme.colorschemes." .. name .. '.' .. style)

  -- Start modifications below here ----------------------

  -- █▄▀ █ ▀█▀ ▀█▀ █▄█ 
  -- █░█ █ ░█░ ░█░ ░█░ 

  if theme.integrations.kitty then
    local cmd = "kitty +kitten themes --reload-in=all " .. theme.integrations.kitty
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end

  -- █▄░█ █░█ █ █▀▄▀█ 
  -- █░▀█ ▀▄▀ █ █░▀░█ 

  -- This is specific to my personal nvim configuration.
  -- You'll probably have to change this.
  if theme.integrations.nvim then
    -- Write new theme to theme config file
    local nvim = theme.integrations.nvim
    local nvim_theme_cfg = CONFIG .. 'nvim/lua/theme.vim'
    local change_cfg_cmd

    -- If table: values are { theme_name, bg_color }
    -- Else value is just the theme name
    if type(nvim) == "table" then
      change_cfg_cmd = "echo -e 'colorscheme " .. nvim[1] .. "' > " .. nvim_theme_cfg .. " ; "
      change_cfg_cmd = change_cfg_cmd .. "echo -e ':set bg=" .. nvim[2] .. "' >> " .. nvim_theme_cfg
    else
      change_cfg_cmd = "echo 'colorscheme " .. nvim .. "' > " .. nvim_theme_cfg
    end

    awful.spawn.easy_async_with_shell(change_cfg_cmd, function()
      -- Then run script to reload config for every running nvim instance
      local awcfg = gfs.get_configuration_dir()
      local nvchad_reload = "python " .. awcfg .. "utils/scripts/nvim-reload.py"
      local reload_theme_cmd = nvchad_reload .. " " .. nvim_theme_cfg
      awful.spawn.easy_async_with_shell(reload_theme_cmd, function() end)
    end)
  end
end
