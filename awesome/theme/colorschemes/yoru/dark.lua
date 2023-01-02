
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
colorscheme.wall_path = "/home/alexis/Pictures/Wallpapers/decay/dark/shore_00.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#df5b61",
  "#78b892",
  "#5a84bc",
  "#6791c9",
  "#f1cf8a",
  "#c58cec",
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
colorscheme.colors.fg_alt  = "#27292a" -- asdf
colorscheme.colors.fg_sub  = "#666c79" -- asdf

colorscheme.colors.main_accent = "#6791c9"
colorscheme.colors.red         = "#df5b61"
colorscheme.colors.green       = "#78b892"
colorscheme.colors.yellow      = "#f1cf8a"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
colorscheme.override.wibar_focused  = "#6791c9"
colorscheme.override.wibar_occupied = "#edeff0"
colorscheme.override.wibar_empty    = "#363c49"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty    = "Yoru"
colorscheme.switcher.nvchad   = "yoru"
colorscheme.switcher.gtk      = "Nordic"
colorscheme.switcher.zathura  = "kanagawa"

return colorscheme
