
-- █▄░█ █▀█ █▀█ █▀▄   █▀▄ ▄▀█ █▀█ █▄▀
-- █░▀█ █▄█ █▀▄ █▄▀   █▄▀ █▀█ █▀▄ █░█

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/nord_dark.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
-- Official colors
theme.nord0  = "#2e3440"   -- Polar night
theme.nord1  = "#3b4252"
theme.nord2  = "#434c5e"
theme.nord3  = "#4c566a"
theme.nord4  = "#d8dee9"   -- Snow storm
theme.nord5  = "#e5e9f0"
theme.nord6  = "#eceff4"
theme.nord7  = "#8fbcbb"   -- Frost
theme.nord8  = "#88c0d0"
theme.nord9  = "#81a1c1"
theme.nord10 = "#5e81ac"
theme.nord11 = "#bf616a"  -- Aurora
theme.nord12 = "#d08770"
theme.nord13 = "#ebcb8b"
theme.nord14 = "#a3be8c"
theme.nord15 = "#b48ead"

-- Other
theme.nord16 = "#20242c"
theme.nord17 = "#272c36"
theme.nord18 = "#373e4d"
theme.transparent = "#ffffff00"

theme.accents = {
  theme.nord7,
  theme.nord8,
  theme.nord9,
  theme.nord10,
  theme.nord11,
  theme.nord12,
  theme.nord13,
  theme.nord14,
  theme.nord15,
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide

-- background colors
theme.base          = theme.nord16  -- dark bg
theme.crust         = theme.nord17  -- medium bg
theme.mantle        = theme.nord0   -- light bg
theme.surface0      = theme.nord18  -- bg for interactive elements (eg buttons)
theme.surface1      = theme.nord0   -- slightly darker version of above 
theme.overlay0      = theme.nord0   -- currently only used for album art filter 
theme.overlay1      = theme.nord2   -- border colors

-- typography
theme.fg            = theme.nord4   -- main text
theme.subtitle      = theme.nord3   -- secondary text
theme.subtext       = theme.nord2   -- tertiary text
theme.main_accent   = theme.nord10  -- primary accent color

-- misc (used in task, battery, and finance widgets)
theme.red    = theme.nord11
theme.green  = theme.nord14
theme.yellow = theme.nord13

-- changing colors up to this point should be all you need
-- to change the entire color scheme.
-- but if you want even more fine-grained color customization, 
-- you can control the colors for almost every single UI element 
-- in theme.lua.

-- theme switcher
theme.kitty = "Nord"
theme.nvim = "nord"

return theme
