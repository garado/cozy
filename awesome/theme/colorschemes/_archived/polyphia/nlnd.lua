
-- █▄░█ █▀▀ █░█░█    █░░ █▀▀ █░█ █▀▀ █░░ █▀ 
-- █░▀█ ██▄ ▀▄▀▄▀    █▄▄ ██▄ ▀▄▀ ██▄ █▄▄ ▄█ 
-- █▄░█ █▀▀ █░█░█    █▀▄ █▀▀ █░█ █ █░░ █▀ 
-- █░▀█ ██▄ ▀▄▀▄▀    █▄▀ ██▄ ▀▄▀ █ █▄▄ ▄█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/polyphia_nlnd.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#a39ec4",
  "#c49ec4",
  "#c4c19e",
  "#c49ea0",
  "#ceb188",
  "#9ec3c4",
  "#9ec49f",
  "#a5b4cb",
}

colorscheme.colors.bg      = "#191919"
colorscheme.colors.bg_l0   = "#222222"
colorscheme.colors.bg_l1   = "#292929"
colorscheme.colors.bg_l2   = "#303030"
colorscheme.colors.bg_l3   = "#3d3d3d"
colorscheme.colors.fg      = "#f0f0f0"
colorscheme.colors.fg_alt  = "#4c4c4c"
colorscheme.colors.fg_sub  = "#767676"

colorscheme.colors.main_accent = "#c49ea0"
colorscheme.colors.red         = "#c49ea0"
colorscheme.colors.green       = "#89ab8a"
colorscheme.colors.yellow      = "#c4c19e"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 


-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Mountain Fuji"
colorscheme.switcher.nvchad  = "mountain"
colorscheme.switcher.zathura = "mountain_fuji"

return colorscheme
