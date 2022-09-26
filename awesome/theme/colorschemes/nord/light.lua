
-- █▄░█ █▀█ █▀█ █▀▄    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▄ █ █▄█ █▀█ ░█░ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/nord_light.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#8fbcbb",
  "#88c0d0",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#b46b54",
  "#c18401",
  "#a3be8c",
  "#b48ead",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0   = "#dee4ef"
theme.bg      = "#d8dee9"
theme.bg_l0   = "#ced4df"
theme.bg_l1   = "#bac0cb"
theme.bg_l2   = "#b0b6c1"
theme.bg_l3   = "#a1a7b2"
theme.fg      = "#2e3440"
theme.fg_sub  = "#4c566a"
theme.fg_alt  = "#6e788f"

theme.main_accent = "#6181a1"
theme.red         = "#bf616a"
theme.green       = "#75905e"
theme.yellow      = "#ebcb8b"
theme.transparent = "#ffffff00"

-- custom
theme.wibar_fg       = "#2e3440"
theme.wibar_occupied = "#a1a7b2"
-- theme.wibar_bg       = "#2e3440"
-- theme.wibar_focused  = "#6181a1"
-- theme.wibar_occupied = "#eceff4"
-- theme.wibar_empty    = "#4c566a"

-- theme.wibar_fg       = "#dee4ef"
-- theme.wibar_bg       = "#2e3440"
-- theme.wibar_focused  = "#6181a1"
-- theme.wibar_occupied = "#eceff4"
-- theme.wibar_empty    = "#4c566a"

-- theme switcher settings
theme.kitty   = "Nord Light"
theme.nvchad  = "onenord_light"
theme.gtk     = "Graphite-Light-nord"
theme.zathura = "nord_light"

return theme
