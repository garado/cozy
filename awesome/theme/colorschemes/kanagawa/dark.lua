
-- █▄▀ ▄▀█ █▄░█ ▄▀█ █▀▀ ▄▀█ █░█░█ ▄▀█    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █░█ █▀█ █░▀█ █▀█ █▄█ █▀█ ▀▄▀▄▀ █▀█    █▄▀ █▀█ █▀▄ █░█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/kanagawa_dark.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#c34043",
  "#dca561",
  "#6a9589",
  "#ffa066",
  "#658594",
  "#7e9cd8",
  "#938aa9",
  "#98bb6c",
  "#d27e99",
}

colorscheme.colors.bg_d0   = "#101017"
colorscheme.colors.bg      = "#16161d"
colorscheme.colors.bg_l0   = "#1f1f28"
colorscheme.colors.bg_l1   = "#232331"
colorscheme.colors.bg_l2   = "#363646"
colorscheme.colors.bg_l3   = "#54546d"
colorscheme.colors.fg      = "#dcd7ba"
colorscheme.colors.fg_alt  = "#c8c093"
colorscheme.colors.fg_sub  = "#727169"

colorscheme.colors.main_accent = "#2d4f67"
colorscheme.colors.red         = "#c34043"
colorscheme.colors.green       = "#76946a"
colorscheme.colors.yellow      = "#dca561"
colorscheme.colors.transparent = "#ffffff00"

colorscheme.colors.gradient = {
  [0] = "#16161d",
  [1] = "#1c283d",
  [2] = "#21354d",
  [3] = "#263f5d",
  [4] = "#29475d",
  [5] = "#2d4f6d",
}

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty    = "kanagawabones"
colorscheme.switcher.nvchad   = "kanagawa"
colorscheme.switcher.gtk      = "Nordic"
colorscheme.switcher.zathura  = "kanagawa"
colorscheme.switcher.rofi     = "kanagawa"

return colorscheme
