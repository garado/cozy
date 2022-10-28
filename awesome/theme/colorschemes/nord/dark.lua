
-- █▄░█ █▀█ █▀█ █▀▄   █▀▄ ▄▀█ █▀█ █▄▀
-- █░▀█ █▄█ █▀▄ █▄▀   █▄▀ █▀█ █▀▄ █░█
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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/nord_dark.jpeg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#8fbcbb",
  "#88c0d0",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#d08770",
  "#ebcb8b",
  "#a3be8c",
  "#b48ead",
}

colorscheme.colors.bg_d0   = "#1a1e26"
colorscheme.colors.bg      = "#20242c"
colorscheme.colors.bg_l0   = "#272c36"
colorscheme.colors.bg_l1   = "#2e3440"
colorscheme.colors.bg_l2   = "#3b4252"
colorscheme.colors.bg_l3   = "#434c5e"
colorscheme.colors.fg      = "#d8dee9"
colorscheme.colors.fg_sub  = "#606a7e"
colorscheme.colors.fg_alt  = "#4d5668"

colorscheme.colors.main_accent = "#5e81ac"
colorscheme.colors.red         = "#bf616a"
colorscheme.colors.green       = "#a3be8c"
colorscheme.colors.yellow      = "#ebcb8b"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_occupied = "#d8dee9"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Nord"
colorscheme.switcher.nvchad  = "nord"
colorscheme.switcher.gtk     = "Nordic"
colorscheme.switcher.zathura = "nord_dark"

return colorscheme
