
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▀ █▀█ █▀▄ █░█ 
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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_dark.png"

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
  "#f9f5d7",
}

colorscheme.colors.bg      = "#1d2021"
colorscheme.colors.bg_l0   = "#282828"
colorscheme.colors.bg_l1   = "#383635"
colorscheme.colors.bg_l2   = "#504945"
colorscheme.colors.bg_l3   = "#7c6f64"
colorscheme.colors.fg      = "#fbf1c7"
colorscheme.colors.fg_alt  = "#d5c4a1"
colorscheme.colors.fg_sub  = "#928374"

colorscheme.colors.main_accent = "#928374"
colorscheme.colors.red         = "#fb4934"
colorscheme.colors.green       = "#b8bb26"
colorscheme.colors.yellow      = "#fabd2f"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused = "#504945"
colorscheme.override.wibar_empty   = "#282828"
colorscheme.override.prof_pfp_bg   = "#383635"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty = "Gruvbox Dark"
colorscheme.switcher.nvchad  = "gruvbox"
colorscheme.switcher.gtk   = "Gruvbox-Dark-B"

return colorscheme
