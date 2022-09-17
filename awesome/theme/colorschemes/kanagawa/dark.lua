
-- █▄▀ ▄▀█ █▄░█ ▄▀█ █▀▀ ▄▀█ █░█░█ ▄▀█    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █░█ █▀█ █░▀█ █▀█ █▄█ █▀█ ▀▄▀▄▀ █▀█    █▄▀ █▀█ █▀▄ █░█ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/kanagawa_dark.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#c34043",
  "#dca561",
  "#6a9589",
  "#ffa066",
  "#658594",
  "#7e9cd8",
  "#938aa9",
  "#98bb6c",
  "#d27e99",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#101017"
theme.bg    = "#16161d" -- base
theme.bg_l0 = "#1f1f28" -- crust
theme.bg_l1 = "#2a2a37" -- mantle
theme.bg_l2 = "#363646" -- surface0
theme.bg_l3 = "#54546d" -- overlay0?
theme.fg    = "#dcd7ba" -- fg
theme.fg_l  = "#c8c093" -- subtitle
theme.fg_d  = "#727169" -- subtitle

theme.main_accent = "#2d4f67" -- overlay1 (border color)
theme.red         = "#c34043"
theme.green       = "#76946a"
theme.yellow      = "#dca561"
theme.transparent = "#ffffff00"

-- custom
--theme.hab_uncheck_bg = "#2a2a37"

-- theme switcher settings
theme.kitty = "kanagawabones"
theme.nvim  = "kanagawa"
theme.gtk   = "Nordic"

return theme
