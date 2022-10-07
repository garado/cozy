
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █░░ █ █▀▀ █░█ ▀█▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▄ █ █▄█ █▀█ ░█░ 
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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_light.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#cc241d",
  "#98971a",
  "#d79921",
  "#458588",
  "#b16286",
  "#689d6a",
  "#7c6f64",
  "#d65d0e",
}

colorscheme.colors.bg      = "#ebdbb2"
colorscheme.colors.bg_l0   = "#d5c4a1"
colorscheme.colors.bg_l1   = "#bdae93"
colorscheme.colors.bg_l2   = "#a89984"
colorscheme.colors.bg_l3   = "#7c6f64"
colorscheme.colors.fg      = "#282828"
colorscheme.colors.fg_alt  = "#998a75"
colorscheme.colors.fg_sub  = "#7c6f64"

colorscheme.colors.main_accent = "#504945"
colorscheme.colors.red         = "#9d0006"
colorscheme.colors.green       = "#79740e"
colorscheme.colors.yellow      = "#d79921"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.hab_check_fg  = "#ebdbb2"
colorscheme.override.wibar_empty   = "#d5c4a1"
colorscheme.override.prof_pfp_bg   = "#bdae93"
colorscheme.override.mus_filter_1  = "#bdae93"
colorscheme.override.mus_filter_2  = "#d5c4a1"
colorscheme.override.ctrl_uptime   = "#282828"
colorscheme.override.notif_bg      = "#ebdbb2"
colorscheme.override._border_color_active = "#d79921"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Gruvbox Light Soft"
colorscheme.switcher.nvchad  = "gruvbox_light"
colorscheme.switcher.gtk     = "Gruvbox-Light-B"
colorscheme.switcher.zathura = "gruvbox_light"

return colorscheme
