
-- █▄░█ █▀█ █▀█ █▀▄    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▄ █ █▄█ █▀█ ░█░ 

local gfs = require("gears.filesystem")
local colors    = {}
local override  = {}
local switcher  = {}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 

local theme_dir = gfs.get_configuration_dir() .. "theme/colorschemes/nord/"
local wall_path = theme_dir .. "light.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

colors.accents = {
  "#729696",
  "#6d99a6",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#b46b54",
  "#c18401",
  "#75905e",
  "#9e6d95",
}

-- For dark themes, 0 is darkest
-- For light themes, 0 is lightest
colors.bg_0 = "#d8dee9"
colors.bg_1 = "#c7ceda"
colors.bg_2 = "#b7becb"
colors.bg_3 = "#a7aebd"
colors.bg_4 = "#979fae"
colors.bg_5 = "#8790a0"
colors.bg_6 = "#788192"

-- colors.bg_0   = "#d8dee9"
-- colors.bg_1   = "#ced4df"
-- colors.bg_2   = "#bac0cb"
-- colors.bg_3   = "#b0b6c1"
-- colors.bg_4   = "#a1a7b2"
-- colors.bg_5   = "#a1a7b2"

colors.fg_0 = "#2e3440"
colors.fg_1 = "#3a4659"
colors.fg_2 = "#455874"

colors.primary_0 = "#5e81ac"
colors.primary_1 = "#506c91"
colors.primary_2 = "#455874"
colors.primary_3 = "#384458"
colors.primary_4 = "#2a313d"

colors.red         = "#bf616a"
colors.green       = "#75905e"
colors.yellow      = "#ebcb8b"

colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 

override.wibar_focused  = "#5e81ac"
override.wibar_occupied = "#eceff4"
override.wibar_empty    = "#4c566a"
override.wibar_bg       = "#292f3c"
override.wibar_fg       = "#eceff4"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

switcher.kitty   = "Nord Light"
switcher.nvchad  = "onenord_light"
switcher.gtk     = "Graphite-Light-nord"
switcher.zathura = "nord_light"
switcher.firefox = "nord-light"

return {
  colors    = colors,
  override  = override,
  switcher  = switcher,
  wall_path = wall_path,
}
