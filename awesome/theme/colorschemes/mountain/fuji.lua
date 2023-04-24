
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ ▀  █▀▀ █░█ ░░█ █ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ▄  █▀░ █▄█ █▄█ █ 

local gfs = require("gears.filesystem")
local colors   = {}
local override = {}
local switcher = {}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄

local theme_dir = gfs.get_configuration_dir() .. "theme/colorschemes/mountain/"
local wall_path = theme_dir .. "fuji.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

colors.accents = {
  "#a39ec4",
  "#c49ec4",
  "#c4c19e",
  "#c49ea0",
  "#ceb188",
  "#9ec3c4",
  "#9ec49f",
  "#a5b4cb",
}

colors.bg_0 = "#0f0f0f"
colors.bg_1 = "#141414"
colors.bg_2 = "#191919"
colors.bg_3 = "#1d1d1d"
colors.bg_4 = "#222222"
colors.bg_5 = "#272727"
colors.bg_6 = "#2c2c2c"

colors.fg_0 = "#dedede"
colors.fg_1 = "#707070"
colors.fg_2 = "#4c4c4c"

colors.primary_0 = "#8a98ac"
colors.primary_1 = "#6b788a"
colors.primary_2 = "#525962"
colors.primary_3 = "#37393c"
colors.primary_4 = "#191919"

colors.red    = "#c49ea0"
colors.green  = "#89ab8a"
colors.yellow = "#c4c19e"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄

override.border_color_active = colors.primary_1

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

switcher.kitty   = "Mountain Fuji"
switcher.nvchad  = "mountain"
switcher.zathura = "mountain_fuji"
switcher.rofi    = "mountain-fuji"
switcher.firefox = "mountain-fuji"
switcher.start   = "mountain-fuji"

return {
  colors   = colors,
  switcher = switcher,
  override = override,
  wall_path = wall_path,
}
