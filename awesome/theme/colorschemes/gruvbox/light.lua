
-- █▀▀ █▀█ █░█ █░█ █▄▄ █▀█ ▀▄▀    █░░ █ █▀▀ █░█ ▀█▀ 
-- █▄█ █▀▄ █▄█ ▀▄▀ █▄█ █▄█ █░█    █▄▄ █ █▄█ █▀█ ░█░ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/gruvbox_light.png"
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
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#f5ebc1"
theme.bg    = "#fbf1c7"
theme.bg_l0 = "#ebdbb2"
theme.bg_l1 = "#d5c4a1"
theme.bg_l2 = "#bdae93"
theme.bg_l3 = "#bdae93"
theme.fg    = "#282828"
theme.fg_l  = "#504945"
theme.fg_d  = "#7c6f64"

theme.main_accent = "#504945"
theme.red         = "#9d0006"
theme.green       = "#79740e"
theme.yellow      = "#d79921"
theme.transparent = "#ffffff00"

-- Custom
--theme.wibar_bg = "#928374"
--theme.wibar_occupied = "#665c54"
--theme.prof_pfp_bg = "#a89984"
--theme.hab_check_bg = "#665c54"
--theme.hab_check_fg = "#fcf1c7"
--theme.hab_uncheck_bg = "#bdae93"
--theme.hab_uncheck_fg = "#a89984"

-- theme switcher
theme.kitty = "Gruvbox Light Soft"
theme.nvim  = "gruvbox_light"
theme.gtk   = "Gruvbox-Light-B"

return theme
