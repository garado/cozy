
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    █░░ ▄▀█ ▀█▀ ▀█▀ █▀▀ 
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    █▄▄ █▀█ ░█░ ░█░ ██▄ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_latte.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.transparent = "#ffffff00"

theme.accents = {
  "#dc8a78",
  "#dd7878",
  "#ea76cb",
  "#8839ef",
  "#d20f39",
  "#e64553",
  "#fe640b",
  "#df8e1d",
  "#40a02b",
  "#179299",
  "#04a5e5",
  "#209fb5",
  "#1e66f5",
  "#7287fd",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#"
theme.bg    = "#eff1f5"
theme.bg_l0 = "#e6e9ef"
theme.bg_l1 = "#dce0e8"
theme.bg_l2 = "#ccd0da"
theme.bg_l3 = "#bcc0cc"
theme.fg    = "#4c4f69"
theme.fg_l  = "#6c6f85"
theme.fg_d  = "#6c6f85"

theme.main_accent = "#7287fd"
theme.red         = "#e78284"
theme.green       = "#40a02b"
theme.yellow      = "#df8e1d"

-- custom
--theme.wibar_bg = "#dce0e8"
--theme.wibar_occupied = "#9ca0b0"
--theme.wibar_empty = "#ccd0da"
--theme.wibar_focused = "#b0b4ed"
--theme.hab_check_fg = "#dce0e8"
--theme.prof_pfp_bg = "#ccd0da"

-- settings for theme switcher
theme.kitty = "Catppuccin-Latte"
theme.nvim  = "catppuccin_latte"
theme.gtk   = "Catppuccin-Latte-Mauve"

return theme
