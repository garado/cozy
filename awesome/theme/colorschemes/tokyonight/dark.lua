
-- ▀█▀ █▀█ █▄▀ █▄█ █▀█   █▄░█ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █░█ ░█░ █▄█   █░▀█ █ █▄█ █▀█ ░█░

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/tokyo_night.jpg"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

-- Colors taken from:
-- https://github.com/folke/tokyonight.nvchad

theme.accents = {
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

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#141520"
theme.bg    = "#1a1b26"
theme.bg_l0 = "#222331"
theme.bg_l1 = "#1f2335"
theme.bg_l2 = "#292e42"
theme.bg_l3 = "#414868"
theme.fg    = "#a9b1d6"
theme.fg_alt  = "#c0caf5"
theme.fg_sub  = "#414868"

theme.main_accent   = "#3d59a1"
theme.red         = "#f7768e"
theme.green       = "#9ece6a"
theme.yellow      = "#e0af68"
theme.transparent = "#ffffff00"

-- custom
--theme.hab_uncheck_bg    = "#292e42"
--theme.notif_actions_bg  = "#292e42"

-- theme switcher
theme.kitty = "Tokyo Night"
theme.nvchad  = "tokyonight"
theme.gtk   = "Tokyonight-Dark-B"

return theme
