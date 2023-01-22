
-- █▀█ █▀█ █▀ █▀▀    █▀█ █ █▄░█ █▀▀    █▀▄ ▄▀█ █░█░█ █▄░█ 
-- █▀▄ █▄█ ▄█ ██▄    █▀▀ █ █░▀█ ██▄    █▄▀ █▀█ ▀▄▀▄▀ █░▀█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/colorschemes/rose-pine/dawn.jpg"

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
colorscheme.colors.bg      = "#faf4ed"
colorscheme.colors.bg_l0   = "#f2e9e1"
colorscheme.colors.bg_l1   = "#eaded5"
colorscheme.colors.bg_l2   = "#e2d3c9"
colorscheme.colors.bg_l3   = "#d2bdb1"
colorscheme.colors.fg      = "#575279"
colorscheme.colors.fg_alt  = "#797593"
colorscheme.colors.fg_sub  = "#907aa9"

colorscheme.colors.main_accent = "#907aa9"
colorscheme.colors.red         = "#b4637a"
colorscheme.colors.green       = "#56949f"
colorscheme.colors.yellow      = "#ea9d34"
colorscheme.colors.purple      = "#907aa9"
colorscheme.colors.transparent = "#ffffff00"

-- https://colordesigner.io/gradient-generator
colorscheme.colors.gradient = {
  [0] = "#eaded5",
  [1] = "#e2d3c9",
  [2] = "#e3b29f",
  [3] = "#de9a8c",
  [4] = "#d7827e",
}

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused  = "#575279"
colorscheme.override.wibar_occupied = "#c2ada1"
colorscheme.override.wibar_empty    = "#eaded5"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty    = "Rosé Pine Dawn"
colorscheme.switcher.nvchad   = "rosepine-dawn"
-- colorscheme.switcher.rofi     = "yoru"
-- colorscheme.switcher.gtk      = "Nordic"

return colorscheme
