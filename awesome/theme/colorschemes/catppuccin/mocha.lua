
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    

-- █▀▄▀█ █▀█ █▀▀ █░█ ▄▀█ 
-- █░▀░█ █▄█ █▄▄ █▀█ █▀█ 


local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_mocha.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#cba6f7",
  "#f38ba8",
  "#fab387",
  "#f9e2af",
  "#a6e3a1",
  "#94e2d5",
  "#74c7ec",
  "#89b4fa",
  "#b4befe",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- background colors
theme.base          = "#11111b"  -- dark bg
theme.crust         = "#191925"  -- medium bg
theme.mantle        = "#181825"  -- light bg
theme.surface0      = "#363a4f"  -- bg for interactive elements (eg buttons)
theme.surface1      = "#494d64"  -- slightly darker version of above 
theme.overlay0      = "#6c7086"  -- currently only used for album art filter 
theme.overlay1      = "#8087a2"  -- border colors

-- typography
theme.fg            = "#cad3f5"  -- main text
theme.subtitle      = "#bac2de"  -- secondary text
theme.subtext       = "#a6adc8"  -- tertiary text
theme.main_accent   = "#89b4fa"  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#f38ba8"
theme.green  = "#a6e3a1"
theme.yellow = "#f9e2af"
theme.transparent = "#ffffff00"

-- custom
theme.hab_uncheck_fg  = "#5b6078"
theme.hab_uncheck_bg  = "#494d64"
theme.hab_check_fg    = "#363a4f"
theme.hab_check_bg    = "#89b4fa"
theme.switcher_options_bg = "#11111b"

-- settings for theme switcher
theme.kitty = "Catppuccin-Mocha"
theme.nvim  = "catppuccin"
theme.gtk   = "Catppuccin-Mocha-Mauve"

return theme
