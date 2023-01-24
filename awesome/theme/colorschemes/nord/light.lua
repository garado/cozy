
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
colorscheme.wall_path = awesome_cfg .. "theme/colorschemes/nord/light.jpg"
colorscheme.override.lockscreen_bg = awesome_cfg .. "theme/colorschemes/nord/light_lockscreen.jpg"

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

colorscheme.colors.gradient = { -- needs work
  [0] = "#bac0cb",
  [1] = "#b0b6c1",
  [2] = "#4c566a",
  [3] = "#4d6688",
  [4] = "#5e81ac",
}

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused  = "#6181a1"
colorscheme.override.wibar_occupied = "#2e3440"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Nord Light"
colorscheme.switcher.nvchad  = "onenord_light"
colorscheme.switcher.gtk     = "Graphite-Light-nord"
colorscheme.switcher.zathura = "nord_light"

return colorscheme
