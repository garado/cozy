
-- █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ █░█ █▀▀ █▀▀ █ █▄░█    
-- █▄▄ █▀█ ░█░ █▀▀ █▀▀ █▄█ █▄▄ █▄▄ █ █░▀█    

-- █▀▄▀█ █▀█ █▀▀ █░█ ▄▀█ 
-- █░▀░█ █▄█ █▄▄ █▀█ █▀█ 


local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/catppuccin_mocha.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

theme.accents = {
  "#cba6f7",
  "#f38ba8",
  "#fab387",
  "#f9e2af",
  "#a6e3a1",
  "#94e2d5",
  "#74c7ec",
  "#89b4fa",
  "#b4befe",
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

theme.bg      = "#11111b"
theme.bg_l0   = "#181825"
theme.bg_l1   = "#1e1e2e"
theme.bg_l2   = "#313244"
theme.bg_l3   = "#45475a"
theme.fg      = "#cdd6f4"
theme.fg_alt  = "#585b70"
theme.fg_sub  = "#585b70"

theme.main_accent = "#89b4fa"
theme.red         = "#f38ba8"
theme.green       = "#a6e3a1"
theme.yellow      = "#f9e2af"
theme.transparent = "#ffffff00"

---- custom
theme.hab_selected_bg = "#d20f39"
theme.hab_check_fg    = "#1e1e2e"

-- settings for theme switcher
theme.kitty = "Catppuccin-Mocha"
theme.nvchad  = "catppuccin"
theme.gtk   = "Catppuccin-Mocha-Mauve"

return theme
