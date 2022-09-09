
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

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- background colors
theme.base          = "#20242c" -- dark bg
theme.crust         = "#272c36" -- medium bg
theme.mantle        = "#2e3440" -- light bg
theme.surface0      = "#373e4d" -- bg for interactive elements (eg buttons)
theme.surface1      = "#2e3440" -- slightly darker version of above 
theme.overlay0      = "#2e3440" -- currently only used for album art filter 
theme.overlay1      = "#434c5e" -- border colors

-- typography
theme.fg            = "#d8dee9" -- main text
theme.subtitle      = "#4c566a" -- secondary text
theme.subtext       = "#434c5e" -- tertiary text
theme.main_accent   = "#5e81ac" -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#bf616a"
theme.green  = "#a3be8c"
theme.yellow = "#ebcb8b"
theme.transparent = "#ffffff00"

-- theme switcher settings
theme.kitty = "Nord"
theme.nvim  = "nord"
theme.gtk   = "Nordic"

return theme
