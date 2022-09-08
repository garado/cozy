
-- ▀█▀ █▀█ █▄▀ █▄█ █▀█   █▄░█ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █░█ ░█░ █▄█   █░▀█ █ █▄█ █▀█ ░█░

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/tokyo_night.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

-- Colors taken from:
-- https://github.com/folke/tokyonight.nvim

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

theme.red         = "#f7768e"
theme.green       = "#9ece6a"
theme.yellow      = "#e0af68"
theme.transparent = "#ffffff00"

-- background colors
theme.base          = "#1a1b26" -- dash, wibar
theme.crust         = "#222331" -- widget bg
theme.mantle        = "#1f2335"
theme.surface0      = "#292e42" -- dash button bg 
theme.surface1      = "#545c7e" 
theme.overlay0      = "#292e42" -- album art filters

-- typography
theme.fg            = "#c0caf5" -- main text
theme.subtitle      = "#a9b1d6" 
theme.subtext       = "#a9b1d6" 
theme.main_accent   = "#3d59a1" 

-- custom
theme.hab_uncheck_bg    = "#292e42"
theme.notif_actions_bg  = "#292e42"

-- theme switcher
theme.kitty = "Tokyo Night"
theme.nvim = "tokyonight"

return theme
