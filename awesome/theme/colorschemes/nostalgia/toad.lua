
-- ▀█▀ █▀█ ▄▀█ █▀▄ 
-- ░█░ █▄█ █▀█ █▄▀ 

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/nostalgia_toad.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#825b69",
  "#69825b",
  "#82755b",
  "#5b6982",
  "#755b82",
  "#5b8275",
  "#494949",
  "#333333",
  "#bda0aa",
  "#aabda0",
  "#bdb3a0",
  "#7484a2",
  "#b3a0bd",
  "#a0bdb3",
  "#494847",
}

colorscheme.colors.bg_d0   = "#d9d5ba"
colorscheme.colors.bg      = "#d9d5ba"
colorscheme.colors.bg_l0   = "#c5c1a6"
colorscheme.colors.bg_l1   = "#bbb79c"
colorscheme.colors.bg_l2   = "#a7a388"
colorscheme.colors.bg_l3   = "#938f74"
colorscheme.colors.fg      = "#444444"
colorscheme.colors.fg_sub  = "#808080"
colorscheme.colors.fg_alt  = "#949494"

colorscheme.colors.main_accent = "#5b8275"
colorscheme.colors.red         = "#825b69"
colorscheme.colors.green       = "#aabda0"
colorscheme.colors.yellow      = "#d9d5ba"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
-- colorscheme.override.wibar_occupied = "#d8dee9"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Nostalgia Light"
colorscheme.switcher.nvchad  = "nostalgia_light"
-- colorscheme.switcher.gtk     = "Nordic"
-- colorscheme.switcher.zathura = "nord_dark"

return colorscheme
