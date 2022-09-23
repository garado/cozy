
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ 
-- ==== Hotaka (Light) variant =====

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/wall45.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#ceb188",
  "#9ec49f",
  "#9ec3c4",
  "#c4c19e",
  "#c49ec4",
  "#c49ea0",
  "#a39ec4",
  "#d2c4c6",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg      = "#f0f0f0"
theme.bg_l0   = "#e7e7e7"
theme.bg_l1   = "#d6d6d6"
theme.bg_l2   = "#b5b5b5"
theme.bg_l3   = "#a1a1a1"

--theme.bg      = "#0f0f0f"
--theme.bg_l0   = "#141414"
--theme.bg_l1   = "#191919"
--theme.bg_l2   = "#262626"
--theme.bg_l3   = "#393939"

theme.fg      = "#111111"
theme.fg_alt  = "#262626"
theme.fg_sub  = "#393939"

--theme.fg      = "#f0f0f0"
--theme.fg_alt  = "#4c4c4c"
--theme.fg_sub  = "#767676"

theme.main_accent = "#7f7399"
theme.red         = "#995c5c"
theme.green       = "#8aac8b"
theme.yellow      = "#c4c19e"
theme.transparent = "#ffffff00"

-- custom
theme.wibar_occupied = "#767676"

-- theme switcher settings
theme.kitty   = "Mountain Hotaka"
theme.nvchad  = "mountain"

return theme
