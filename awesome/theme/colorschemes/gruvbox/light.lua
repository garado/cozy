
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █░░ █ █▀▀ █░█ ▀█▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▄ █ █▄█ █▀█ ░█░ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_light.png"
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
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide

-- background colors
theme.base          = "#fbf1c7"  -- dark bg
theme.crust         = "#f2e5bc"  -- medium bg
theme.mantle        = "#d5c4a1"  -- light bg
theme.surface0      = "#bdae93"  -- bg for interactive elements (eg buttons)
theme.surface1      = "#a89984"  -- slightly darker version of above 
theme.overlay0      = "#d5c4a1"  -- album art filter, selectable buttons
theme.overlay1      = "#665c54"  -- border colors

-- typography
theme.fg            = "#282828"  -- main text
theme.subtitle      = "#3c3836"  -- secondary text
theme.subtext       = "#504945"  -- tertiary text
theme.main_accent   = "#3c3836"  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#9d0006"
theme.green  = "#79740e"
theme.yellow = "#d79921"

-- custom
theme.wibar_bg = "#928374"
theme.wibar_occupied = "#665c54"
theme.pfp_bg = "#a89984"
theme.hab_check_bg = "#665c54"
theme.hab_check_fg = "#fcf1c7"
theme.hab_uncheck_bg = "#bdae93"
theme.hab_uncheck_fg = "#a89984"

-- theme switcher
theme.kitty = "Gruvbox Light Soft"
theme.nvim  = "gruvbox_light"
theme.gtk   = "Gruvbox-Light-B"

return theme
