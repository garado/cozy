
-- █▄█ █▀█ █▀█ █░█ 
-- ░█░ █▄█ █▀▄ █▄█ 

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
colorscheme.wall_path = awesome_cfg .. "theme/colorschemes/yoru/wp.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#df5b61",
  "#78b892",
  "#5a84bc",
  "#6791c9",
  "#f1cf8a",
  "#ac78d0",
  "#70b8ca",
  "#e89982",
}

colorscheme.colors.bg_d0   = "#101213" -- asdf 
colorscheme.colors.bg      = "#0c0e0f"
colorscheme.colors.bg_l0   = "#121415"
colorscheme.colors.bg_l1   = "#161819"
colorscheme.colors.bg_l2   = "#1f2122"
colorscheme.colors.bg_l3   = "#27292a"
colorscheme.colors.fg      = "#edeff0"
colorscheme.colors.fg_alt  = "#363c49" -- asdf
colorscheme.colors.fg_sub  = "#666c79" -- asdf

colorscheme.colors.main_accent = "#6791c9"
colorscheme.colors.red         = "#df5b61"
colorscheme.colors.green       = "#78b892"
colorscheme.colors.yellow      = "#f1cf8a"
colorscheme.colors.purple      = "#ac78d0"
colorscheme.colors.transparent = "#ffffff00"

-- https://colordesigner.io/gradient-generator
colorscheme.colors.gradient = {
  [0] = "#0c0e0f",
  [1] = "#1d2d3f",
  [2] = "#2f4e6f",
  [3] = "#466f9f",
  [4] = "#6791cf",
}

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused  = "#6791c9"
colorscheme.override.wibar_occupied = "#edeff0"
colorscheme.override.wibar_empty    = "#363c49"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty    = "Yoru"
colorscheme.switcher.nvchad   = "yoru"
colorscheme.switcher.rofi     = "yoru"
colorscheme.switcher.firefox  = "yoru"
colorscheme.switcher.start    = "yoru"

return colorscheme
