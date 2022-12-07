
-- █▄░█ █▀█ █▀█ █▀▄    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▄ █ █▄█ █▀█ ░█░ 

local gfs = require("gears.filesystem")
local colorscheme = {
  colors = {},
  override = {},
  switcher = {},
  wall_path = nil,
}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/nord_light.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#8fbcbb",
  "#88c0d0",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#b46b54",
  "#c18401",
  "#a3be8c",
  "#b48ead",
}

colorscheme.colors.bg_d0   = "#dee4ef"
colorscheme.colors.bg      = "#d8dee9"
colorscheme.colors.bg_l0   = "#ced4df"
colorscheme.colors.bg_l1   = "#bac0cb"
colorscheme.colors.bg_l2   = "#b0b6c1"
colorscheme.colors.bg_l3   = "#a1a7b2"
colorscheme.colors.fg      = "#2e3440"
colorscheme.colors.fg_sub  = "#4c566a"
colorscheme.colors.fg_alt  = "#6e788f"

colorscheme.colors.main_accent = "#6181a1"
colorscheme.colors.red         = "#bf616a"
colorscheme.colors.green       = "#75905e"
colorscheme.colors.yellow      = "#ebcb8b"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
-- colorscheme.override.wibar_occupied = "#a1a7b2"
colorscheme.override.wibar_bg       = "#2e3440"
colorscheme.override.wibar_focused  = "#6181a1"
colorscheme.override.wibar_occupied = "#eceff4"
colorscheme.override.wibar_empty    = "#4c566a"
colorscheme.override.wibar_fg       = "#eceff4"

-- theme.wibar_fg       = "#dee4ef"
-- theme.wibar_bg       = "#2e3440"
-- theme.wibar_focused  = "#6181a1"
-- theme.wibar_occupied = "#eceff4"
-- theme.wibar_empty    = "#4c566a"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Nord Light"
colorscheme.switcher.nvchad  = "onenord_light"
colorscheme.switcher.gtk     = "Graphite-Light-nord"
colorscheme.switcher.zathura = "nord_light"

return colorscheme
