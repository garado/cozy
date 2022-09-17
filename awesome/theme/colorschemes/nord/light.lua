
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

theme.bg_d0 = "#dee4ef"
theme.bg    = "#d8dee9" -- base
theme.bg_l0 = "#ced4df" -- crust
theme.bg_l1 = "#bac0cb" -- mantle
theme.bg_l2 = "#b0b6c1" -- surface0
theme.bg_l3 = "#a1a7b2" -- overlay0?
theme.fg    = "#2e3440" -- fg
theme.fg_l  = "#434c5e" -- fg
theme.fg_d  = "#434c5e" -- subtitle

theme.main_accent = "#5e81ac"
theme.red         = "#bf616a"
theme.green       = "#75905e"
theme.yellow      = "#ebcb8b"
theme.transparent = "#ffffff00"

-- custom
--theme.wibar_occupied 
--theme.wibar_occupied = "#9fa5b0"
--theme.wibar_empty = "#ced1d6"
--theme.mus_playing_fg = "#d8dee9"
--theme.mus_control_fg = "#d8dee9"

-- theme switcher settings
theme.kitty = "Nord Light"
theme.nvim  = "onenord_light"
theme.gtk   = "Graphite-Light-nord"

return theme
