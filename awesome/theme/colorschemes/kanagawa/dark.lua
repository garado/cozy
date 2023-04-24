
-- █▄▀ ▄▀█ █▄░█ ▄▀█ █▀▀ ▄▀█ █░█░█ ▄▀█    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █░█ █▀█ █░▀█ █▀█ █▄█ █▀█ ▀▄▀▄▀ █▀█    █▄▀ █▀█ █▀▄ █░█ 

local gfs   = require("gears.filesystem")
local colors    = {}
local override  = {}
local switcher  = {}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 

local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/kanagawa_dark.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

colors.accents = {
  "#c34043",
  "#dca561",
  "#6a9589",
  "#ffa066",
  "#658594",
  "#7e9cd8",
  "#938aa9",
  "#98bb6c",
  "#d27e99",
}

colors.bg_0 = "#1a1e26"
colors.bg_1 = "#222732"
colors.bg_2 = "#2a313d"
colors.bg_3 = "#333a48"
colors.bg_4 = "#3b4354"
colors.bg_5 = "#434d5f"
colors.bg_6 = "#4c566a"

colors.bg_d0   = "#101017"
colors.bg      = "#16161d"
colors.bg_l0   = "#1f1f28"
colors.bg_l1   = "#232331"
colors.bg_l2   = "#363646"
colors.bg_l3   = "#54546d"
colors.fg      = "#dcd7ba"
colors.fg_alt  = "#c8c093"
colors.fg_sub  = "#727169"

colors.main_accent = "#2d4f67"
colors.red         = "#c34043"
colors.green       = "#76946a"
colors.yellow      = "#dca561"
colors.transparent = "#ffffff00"

colors.gradient = {
  [0] = "#16161d",
  [1] = "#1c283d",
  [2] = "#21354d",
  [3] = "#263f5d",
  [4] = "#29475d",
  [5] = "#2d4f6d",
}

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
switcher.kitty    = "kanagawabones"
switcher.nvchad   = "kanagawa"
switcher.gtk      = "Nordic"
switcher.zathura  = "kanagawa"
switcher.rofi     = "kanagawa"

return {
  colors    = colors,
  switcher  = switcher,
  override  = override,
  wall_path = wall_path,
}
