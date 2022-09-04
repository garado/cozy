
-- ▀█▀ █▀█ █▄▀ █▄█ █▀█   █▄░█ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █░█ ░█░ █▄█   █░▀█ █ █▄█ █▀█ ░█░

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local math = math

theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/walls/tokyo_night.png")

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
-- Colors taken from:
-- https://github.com/folke/tokyonight.nvim
theme.bg_dark = "#1f2335"  
theme.bg_dark2 = "#222331" -- custom
theme.bg_dark3 = "#1a1b26" -- custom
theme.bg = "#24283b"
theme.bg_highlight = "#292e42"
theme.terminal_black = "#414868"
theme.fg = "#c0caf5"
theme.fg_dark = "#a9b1d6"
theme.fg_gutter = "#3b4261"
theme.dark3 = "#545c7e"
theme.comment = "#565f89"
theme.dark5 = "#737aa2"
theme.blue0 = "#3d59a1"
theme.blue = "#7aa2f7"
theme.cyan = "#7dcfff"
theme.blue1 = "#2ac3de"
theme.blue2 = "#0db9d7"
theme.blue5 = "#89ddff"
theme.blue6 = "#B4F9F8"
theme.blue7 = "#394b70"
theme.magenta = "#bb9af7"
theme.magenta2 = "#ff007c"
theme.purple = "#9d7cd8"
theme.orange = "#ff9e64"
theme.yellow = "#e0af68"
theme.green = "#9ece6a"
theme.green1 = "#73daca"
theme.green2 = "#41a6b5"
theme.teal = "#1abc9c"
theme.red = "#f7768e"
theme.red1 = "#db4b4b"

theme.transparent = "#ffffff00"

theme.accents = {
  theme.blue,
  theme.blue0,
  theme.cyan,
  theme.magenta,
  theme.magenta2,
  theme.orange,
  theme.yellow,
  theme.green,
  theme.teal,
  theme.red,
  theme.green2,
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide
-- background colors
theme.base          = theme.bg_dark3  -- dash, wibar
theme.crust         = theme.bg_dark2  -- widget bg
theme.mantle        = theme.bg_dark
theme.surface0      = theme.bg_highlight -- dash button bg 
theme.surface1      = theme.dark3     --
theme.overlay       = theme.bg_highlight -- album art filters

-- typography
theme.fg            = theme.fg      -- main text
theme.subtitle      = theme.fg_gutter
theme.subtext       = theme.fg_gutter
theme.main_accent   = theme.blue0   -- primary accent color

return theme
