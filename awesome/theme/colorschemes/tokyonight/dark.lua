
-- ▀█▀ █▀█ █▄▀ █▄█ █▀█   █▄░█ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █░█ ░█░ █▄█   █░▀█ █ █▄█ █▀█ ░█░

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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/tokyo_night.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#7aa2f7",
  "#3d59a1",
  "#7dcfff",
  "#bb9af7",
  "#ff007c",
  "#ff9e64",
  "#e0af68",
  "#9ece6a",
  "#1abc9c",
  "#f7768e",
  "#41a6b5",
}

colorscheme.colors.bg_d0 = "#141520"
colorscheme.colors.bg    = "#1a1b26"
colorscheme.colors.bg_l0 = "#222331"
colorscheme.colors.bg_l1 = "#1f2335"
colorscheme.colors.bg_l2 = "#292e42"
colorscheme.colors.bg_l3 = "#414868"
colorscheme.colors.fg    = "#a9b1d6"
colorscheme.colors.fg_alt  = "#c0caf5"
colorscheme.colors.fg_sub  = "#414868"

colorscheme.colors.main_accent   = "#3d59a1"
colorscheme.colors.red         = "#f7768e"
colorscheme.colors.green       = "#9ece6a"
colorscheme.colors.yellow      = "#e0af68"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
--colorscheme..hab_uncheck_bg    = "#292e42"
--colorscheme..notif_actions_bg  = "#292e42"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty = "Tokyo Night"
colorscheme.switcher.nvchad  = "tokyonight"
colorscheme.switcher.gtk   = "Tokyonight-Dark-B"

return colorscheme
