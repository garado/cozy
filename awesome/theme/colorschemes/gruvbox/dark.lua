
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▀ █▀█ █▀▄ █░█ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_dark.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.transparent = "#ffffff00"

theme.accents = {
  "#cc241d",
  "#98971a",
  "#d79921",
  "#458588",
  "#b16286",
  "#689d6a",
  "#7c6f64",
  "#d65d0e",
  "#f9f5d7",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#383635"
theme.bg    = "#282828"
theme.bg_l0 = "#3c3836"
theme.bg_l1 = "#504945"
theme.bg_l2 = "#665c54"
theme.bg_l3 = "#7c6f64"
theme.fg    = "#fbf1c7"
theme.fg_l  = "#d5c4a1"
theme.fg_d  = "#928374"

theme.main_accent = "#928374"
theme.red         = "#fb4934"
theme.green       = "#b8bb26"
theme.yellow      = "#fabd2f"
theme.transparent = "#ffffff00"

-- Custom
--theme.hab_uncheck_bg = "#665c54"
--theme.hab_uncheck_fg = "#7c6f64"
--theme.hab_check_bg = "#d5c4a1"
--theme.hab_check_fg = "#665c54"
--theme.prof_pfp_bg = "#32302f"

-- theme switcher
theme.kitty = "Gruvbox Dark"
theme.nvim  = "gruvbox"
theme.gtk   = "Gruvbox-Dark-B"

return theme
