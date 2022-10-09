
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    █░░ ▄▀█ ▀█▀ ▀█▀ █▀▀ 
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    █▄▄ █▀█ ░█░ ░█░ ██▄ 

-- This theme sucks and I couldn't get it to look right
-- Pull requests from those more aesthetically inclined are very welcome

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_latte.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
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

colorscheme.colors.bg_d0   = "#"
colorscheme.colors.bg      = "#eff1f5"
colorscheme.colors.bg_l0   = "#e6e9ef"
colorscheme.colors.bg_l1   = "#dce0e8"
colorscheme.colors.bg_l2   = "#ccd0da"
colorscheme.colors.bg_l3   = "#bcc0cc"
colorscheme.colors.fg      = "#4c4f69"
colorscheme.colors.fg_alt  = "#6c6f85"
colorscheme.colors.fg_sub  = "#6c6f85"

colorscheme.colors.main_accent = "#7287fd"
colorscheme.colors.red         = "#e78284"
colorscheme.colors.green       = "#40a02b"
colorscheme.colors.yellow      = "#df8e1d"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused = "#b0b4ed"
colorscheme.override.prof_pfp_bg   = "#b0b4ed"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty = "Catppuccin-Latte"
colorscheme.switcher.nvchad  = "catppuccin_latte"
colorscheme.switcher.gtk   = "Catppuccin-Latte-Mauve"

return colorscheme
