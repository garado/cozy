
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    █░░ ▄▀█ ▀█▀ ▀█▀ █▀▀ 
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    █▄▄ █▀█ ░█░ ░█░ ██▄ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_latte.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.transparent = "#ffffff00"

theme.accents = {
  "#dc8a78",
  "#dd7878",
  "#ea76cb",
  "#8839ef",
  "#d20f39",
  "#e64553",
  "#fe640b",
  "#df8e1d",
  "#40a02b",
  "#179299",
  "#04a5e5",
  "#209fb5",
  "#1e66f5",
  "#7287fd",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- background colors
theme.base          = "#eff1f5"  -- dark bg
theme.crust         = "#e6e9ef"  -- medium bg
theme.mantle        = "#e6e9ef"  -- light bg
theme.surface0      = "#ccd0da"  -- bg for interactive elements (eg buttons)
theme.surface1      = "#bcc0cc"  -- slightly darker version of above 
theme.overlay0      = "#acb0be"  -- currently only used for album art filter 
theme.overlay1      = "#9ca0b0"  -- border colors

-- typography
theme.fg            = "#4c4f69"  -- main text
theme.subtitle      = "#5c5f77"  -- secondary text
theme.subtext       = "#6c6f85"  -- tertiary text
theme.main_accent   = "#4c4f69"  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#e78284"
theme.green  = "#40a02b"
theme.yellow = "#df8e1d"

-- custom
theme.wibar_bg = "#dce0e8"
theme.wibar_occupied = "#9ca0b0"
theme.wibar_empty = "#ccd0da"
theme.wibar_focused = "#b0b4ed"
theme.hab_check_fg = "#dce0e8"
theme.pfp_bg = "#ccd0da"

-- settings for theme switcher
theme.kitty = "Catppuccin-Latte"
theme.nvim   = "catppuccin_latte"

return theme
