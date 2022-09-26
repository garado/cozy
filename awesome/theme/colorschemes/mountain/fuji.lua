
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ 
-- ====== Fuji (Dark) variant ======
-- Modified!

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/mountain_modified_fuji.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#a39ec4",
  "#c49ec4",
  "#c4c19e",
  "#c49ea0",
  "#ceb188",
  "#9ec3c4",
  "#9ec49f",
  "#a5b4cb",
  ----------
  "#a39ec4",
  "#c49ec4",
  "#c4c19e",
  "#c49ea0",
  "#ceb188",
  "#9ec3c4",
  "#9ec49f",
  "#a5b4cb",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg      = "#191919"
theme.bg_l0   = "#222222"
theme.bg_l1   = "#292929"
theme.bg_l2   = "#303030"
theme.bg_l3   = "#3d3d3d"

theme.fg      = "#f0f0f0"
theme.fg_alt  = "#4c4c4c"
theme.fg_sub  = "#767676"

theme.main_accent = "#8a98ac"
theme.red         = "#c49ea0"
theme.green       = "#515646"
theme.yellow      = "#c4c19e"
theme.transparent = "#ffffff00"

-- custom
theme.wibar_focused = "#5b6572"

-- theme switcher settings
theme.kitty   = "Mountain Fuji"
theme.nvchad  = "mountain"
theme.zathura = "mountain_fuji"

return theme
