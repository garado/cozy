
-- █▄░█ █▀█ █▀█ █▀▄   █▀▄ ▄▀█ █▀█ █▄▀
-- █░▀█ █▄█ █▀▄ █▄▀   █▄▀ █▀█ █▀▄ █░█

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/nord_dark.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#8fbcbb",
  "#88c0d0",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#d08770",
  "#ebcb8b",
  "#a3be8c",
  "#b48ead",
}

theme.bg_d0   = "#1a1e26"
theme.bg      = "#20242c"
theme.bg_l0   = "#272c36"
theme.bg_l1   = "#2e3440"
theme.bg_l2   = "#3b4252"
theme.bg_l3   = "#434c5e"
theme.fg      = "#d8dee9"
theme.fg_sub  = "#606a7e"
theme.fg_alt  = "#4d5668"

theme.main_accent = "#5e81ac"
theme.red         = "#bf616a"
theme.green       = "#a3be8c"
theme.yellow      = "#ebcb8b"
theme.transparent = "#ffffff00"

-- custom
theme.wibar_occupied = "#d8dee9"

-- theme switcher settings
theme.kitty   = "Nord"
theme.nvchad  = "nord"
theme.gtk     = "Nordic"

return theme
