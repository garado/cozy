
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ ▀  █░█ █▀█ ▀█▀ ▄▀█ █▄▀ ▄▀█ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ▄  █▀█ █▄█ ░█░ █▀█ █░█ █▀█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/hotaka.jpeg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#ceb188",
  "#9ec49f",
  "#9ec3c4",
  "#c4c19e",
  "#c49ec4",
  "#c49ea0",
  "#a39ec4",
  "#d2c4c6",
}

colorscheme.colors.bg      = "#f0f0f0"
colorscheme.colors.bg_l0   = "#e7e7e7"
colorscheme.colors.bg_l1   = "#d6d6d6"
colorscheme.colors.bg_l2   = "#b5b5b5"
colorscheme.colors.bg_l3   = "#a1a1a1"
colorscheme.colors.fg      = "#111111"
colorscheme.colors.fg_alt  = "#262626"
colorscheme.colors.fg_sub  = "#393939"

colorscheme.colors.main_accent = "#7f7399"
colorscheme.colors.red         = "#995c5c"
colorscheme.colors.green       = "#8aac8b"
colorscheme.colors.yellow      = "#c4c19e"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_occupied = "#767676"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Mountain Hotaka"
colorscheme.switcher.nvchad  = "mountain"

return colorscheme
