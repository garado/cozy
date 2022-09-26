
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

theme.bg      = "#ebdbb2"
theme.bg_l0   = "#d5c4a1"
theme.bg_l1   = "#bdae93"
theme.bg_l2   = "#a89984"
theme.bg_l3   = "#7c6f64"
theme.fg      = "#282828"
theme.fg_alt  = "#998a75"
theme.fg_sub  = "#7c6f64"

theme.main_accent = "#504945"
theme.red         = "#9d0006"
theme.green       = "#79740e"
theme.yellow      = "#d79921"
theme.transparent = "#ffffff00"

-- custom
theme.hab_check_fg  = "#ebdbb2"
theme.wibar_empty   = "#d5c4a1"
theme.prof_pfp_bg   = "#bdae93"
theme.mus_filter_1  = "#bdae93"
theme.mus_filter_2  = "#d5c4a1"
theme.ctrl_uptime   = "#282828"
theme.notif_bg      = "#ebdbb2"
theme._border_color_active = "#d79921"

-- theme switcher
theme.kitty   = "Gruvbox Light Soft"
theme.nvchad  = "gruvbox_light"
theme.gtk     = "Gruvbox-Light-B"
theme.zathura = "gruvbox_light"

return theme
