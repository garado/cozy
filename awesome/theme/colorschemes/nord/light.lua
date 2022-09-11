
-- █▄░█ █▀█ █▀█ █▀▄    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▄ █ █▄█ █▀█ ░█░ 

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/nord_light.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#8fbcbb",
  "#88c0d0",
  "#81a1c1",
  "#5e81ac",
  "#bf616a",
  "#b46b54",
  "#c18401",
  "#a3be8c",
  "#b48ead",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- background colors
theme.base          = "#d8dee9" -- dark bg
theme.crust         = "#ced4df" -- medium bg
theme.mantle        = "#eceff4" -- light bg
theme.surface0      = "#bac0cb" -- bg for interactive elements (eg buttons)
theme.surface1      = "#bac0cb" -- slightly darker version of above 
theme.overlay0      = "#6181a1" -- currently only used for album art filter 
theme.overlay1      = "#434c5e" -- border colors

-- typography
theme.fg            = "#2e3440" -- main text
theme.subtitle      = "#434c5e" -- secondary text
theme.subtext       = "#395979" -- tertiary text
theme.main_accent   = "#5e81ac" -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = "#bf616a"
theme.green  = "#75905e"
theme.yellow = "#ebcb8b"
theme.transparent = "#ffffff00"

-- custom
theme.wibar_occupied = "#9fa5b0"
theme.wibar_empty = "#ced1d6"
theme.now_playing_fg = "#d8dee9"
theme.playerctl_fg = "#d8dee9"

-- theme switcher settings
theme.kitty = "Nord Light"
theme.nvim  = "onenord_light"
theme.gtk   = "Graphite-Light-nord"

return theme
