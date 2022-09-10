
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

-- background colors
theme.base          = "#16161d" -- dark bg
theme.crust         = "#1f1f28" -- medium bg
theme.mantle        = "#2a2a37" -- light bg
theme.surface0      = "#252535" -- bg for interactive elements (eg buttons)
theme.surface1      = "#2d4f67" -- slightly darker version of above 
theme.overlay0      = "#2d4f67" -- currently only used for album art filter 
theme.overlay1      = "#717c7c" -- border colors

-- typography
theme.fg            = "#dcd7ba" -- main text
theme.subtitle      = "#dcd7ba" -- secondary text
theme.subtext       = "#dcd7ba" -- tertiary text
theme.main_accent   = "#2d4f67" -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#c34043"
theme.green  = "#76946a"
theme.yellow = "#dca561"
theme.transparent = "#ffffff00"

-- custom
theme.hab_uncheck_bg = "#2a2a37"


-- theme switcher settings
theme.kitty = "kanagawabones"
theme.nvim  = "kanagawa"
theme.gtk   = "Nordic"

return theme
