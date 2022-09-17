
-- █▀▄ █▀█ ▄▀█ █▀▀ █░█ █░░ ▄▀█
-- █▄▀ █▀▄ █▀█ █▄▄ █▄█ █▄▄ █▀█

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/dracula.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.accents = {
  "#6272a4",
  "#8be9fd",
  "#50fa7b",
  "#ffb86c",
  "#ff79c6",
  "#bd93f9",
  "#ff5555",
  "#f1fa8c",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg_d0 = "#13141b"
theme.bg    = "#191a21"
theme.bg_l0 = "#1e1f29"
theme.bg_l1 = "#282a36"
theme.bg_l2 = "#343746"
theme.bg_l3 = "#44475a"
theme.fg    = "#f8f8f2"
theme.fg_l  = "#6272a4"
theme.fg_d  = "#6d43a0"

theme.main_accent = "#6d43a0"
theme.red         = "#ff5555"
theme.yellow      = "#f1fa8c"
theme.green       = "#50fa7b"
theme.transparent = "#ffffff00"

-- for theme switcher
theme.kitty = "Dracula"
theme.nvim  = "chadracula"
theme.gtk   = "Dracula"

return theme
