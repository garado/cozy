
-- █▀█ █▀█ █▀ █▀▀    █▀█ █ █▄░█ █▀▀ 
-- █▀▄ █▄█ ▄█ ██▄    █▀▀ █ █░▀█ ██▄ 

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
colorscheme.wall_path = awesome_cfg .. "theme/colorschemes/rose-pine/pine.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#b4637a",
  "#ea9d34",
  "#286983",
  "#56949f",
  "#907aa9",
  "#75afb1",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
  "#ea9d34",
}

colorscheme.colors.bg_d0   = "#fffaf3"
colorscheme.colors.bg      = "#191724"
colorscheme.colors.bg_l0   = "#1f1d2e"
colorscheme.colors.bg_l1   = "#26233a"
colorscheme.colors.bg_l2   = "#2f2946"
colorscheme.colors.bg_l3   = "#382f52"
colorscheme.colors.fg      = "#e0def4"
colorscheme.colors.fg_alt  = "#908caa"
colorscheme.colors.fg_sub  = "#6e6a86"

colorscheme.colors.main_accent = "#907aa9"
colorscheme.colors.red         = "#eb6f92"
colorscheme.colors.green       = "#9ccfd8"
colorscheme.colors.yellow      = "#f6c177"
colorscheme.colors.purple      = "#c4a7e7"
colorscheme.colors.transparent = "#ffffff00"

-- https://colordesigner.io/gradient-generator
colorscheme.colors.gradient = {
  [0] = "#26233a", -- make sure this looks good on bg_l0
  [1] = "#4d4167",
  [2] = "#62537c",
  [3] = "#796692",
  [4] = "#907aa9",
}

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused  = "#eb6f92"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty    = "Rosé Pine"
colorscheme.switcher.nvchad   = "rosepine"
-- colorscheme.switcher.rofi     = "yoru"
-- colorscheme.switcher.gtk      = "Nordic"

return colorscheme
