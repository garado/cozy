
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▀ █▀█ █▀▄ █░█ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_dark.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.transparent = "#ffffff00"

theme.accents = {
  "#cc241d",
  "#98971a",
  "#d79921",
  "#458588",
  "#b16286",
  "#689d6a",
  "#7c6f64",
  "#d65d0e",
  "#f9f5d7",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide

-- background colors
theme.base          = "#282828"  -- dark bg
theme.crust         = "#32302f"  -- medium bg
theme.mantle        = "#504945"  -- light bg
theme.surface0      = "#665c54"  -- bg for interactive elements (eg buttons)
theme.surface1      = "#7c6f64"  -- slightly darker version of above 
theme.overlay0      = "#504945"  -- currently only used for album art filter 
theme.overlay1      = "#a89984"  -- border colors

-- typography
theme.fg            = "#fbf1c7"  -- main text
theme.subtitle      = "#ebdbb2"  -- secondary text
theme.subtext       = "#d5c4a1"  -- tertiary text
theme.main_accent   = "#928374"  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#fb4934"
theme.green  = "#b8bb26"
theme.yellow = "#fabd2f"

-- changing colors up to this point should be all you need
-- to change the entire color scheme.

-- but if you want even more fine-grained color customization, 
-- see theme.lua for a list of of all ui element names that you can
-- modify. (modify them below)

-- Dash
theme.hab_uncheck_bg = "#665c54"
theme.hab_uncheck_fg = "#7c6f64"
theme.hab_check_bg = "#d5c4a1"
theme.hab_check_fg = "#665c54"
theme.pfp_bg = "#32302f"

-- theme switcher
theme.kitty = "Gruvbox Dark"
theme.nvim  = "gruvbox"
theme.gtk   = "Gruvbox-Dark-B"

return theme
