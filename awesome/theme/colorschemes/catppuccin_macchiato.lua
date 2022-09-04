
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    

-- █▀▄▀█ ▄▀█ █▀▀ █▀▀ █░█ █ ▄▀█ ▀█▀ █▀█ 
-- █░▀░█ █▀█ █▄▄ █▄▄ █▀█ █ █▀█ ░█░ █▄█ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/walls/catppuccin_macchiato.png")

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.transparent = "#ffffff00"

theme.accents = {
  "#c6a0f6",
  "#ed8796",
  "#f5a97f",
  "#eed49f",
  "#a6da95",
  "#8bd5ca",
  "#7dc4e4",
  "#8aadf4",
  "#b7bdf8",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide

-- background colors
theme.base          = "#1e2030"  -- dark bg
theme.crust         = "#24273a"  -- medium bg
theme.mantle        = "#363a4f"  -- light bg
theme.surface0      = "#363a4f"  -- bg for interactive elements (eg buttons)
theme.surface1      = "#494d64"  -- slightly darker version of above 
theme.overlay0      = "#24273a"  -- currently only used for album art filter 
theme.overlay1      = "#8087a2"  -- border colors

-- typography
theme.fg            = "#cad3f5"  -- main text
theme.subtitle      = "#363a4f"  -- secondary text
theme.subtext       = "#a5adcb"  -- tertiary text
theme.main_accent   = "#8aadf4"  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#ed8796"
theme.green  = "#a6da95"
theme.yellow = "#eed49f"

--

theme.hab_uncheck_fg  = "#5b6078"
theme.hab_uncheck_bg  = "#494d64" 
theme.hab_check_fg    = "#363a4f" 
theme.hab_check_bg    = "#8aadf4"

return theme
