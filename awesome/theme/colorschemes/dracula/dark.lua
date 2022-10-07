
-- █▀▄ █▀█ ▄▀█ █▀▀ █░█ █░░ ▄▀█
-- █▄▀ █▀▄ █▀█ █▄▄ █▄█ █▄▄ █▀█
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
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/dracula.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#6272a4",
  "#8be9fd",
  "#50fa7b",
  "#ffb86c",
  "#ff79c6",
  "#bd93f9",
  "#ff5555",
  "#f1fa8c",
}

colorscheme.colors.bg_d0 = "#13141b"
colorscheme.colors.bg    = "#191a21"
colorscheme.colors.bg_l0 = "#1e1f29"
colorscheme.colors.bg_l1 = "#282a36"
colorscheme.colors.bg_l2 = "#343746"
colorscheme.colors.bg_l3 = "#44475a"
colorscheme.colors.fg    = "#f8f8f2"
colorscheme.colors.fg_alt  = "#6272a4"
colorscheme.colors.fg_sub  = "#6d43a0"

colorscheme.colors.main_accent = "#956bc8"
colorscheme.colors.red         = "#ff5555"
colorscheme.colors.yellow      = "#f1fa8c"
colorscheme.colors.green       = "#50fa7b"
colorscheme.colors.transparent = "#ffffff00"


-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty = "Dracula"
colorscheme.switcher.nvchad  = "chadracula"
colorscheme.switcher.gtk   = "Dracula"

return colorscheme
