
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    

-- █▀▄▀█ █▀█ █▀▀ █░█ ▄▀█ 
-- █░▀░█ █▄█ █▄▄ █▀█ █▀█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_mocha.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
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

colorscheme.colors.bg      = "#11111b"
colorscheme.colors.bg_l0   = "#181825"
colorscheme.colors.bg_l1   = "#1e1e2e"
colorscheme.colors.bg_l2   = "#313244"
colorscheme.colors.bg_l3   = "#45475a"
colorscheme.colors.fg      = "#cdd6f4"
colorscheme.colors.fg_alt  = "#585b70"
colorscheme.colors.fg_sub  = "#585b70"

colorscheme.colors.main_accent = "#89b4fa"
colorscheme.colors.red         = "#f38ba8"
colorscheme.colors.green       = "#a6e3a1"
colorscheme.colors.yellow      = "#f9e2af"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.hab_selected_bg = "#d20f39"
colorscheme.override.hab_check_fg    = "#1e1e2e"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty  = "Catppuccin-Mocha"
colorscheme.switcher.nvchad = "catppuccin"
colorscheme.switcher.gtk    = "Catppuccin-Mocha-Mauve"

return colorscheme
