
-- █▄░█ █▀█ █▀█ █▀▄   █▀▄ ▄▀█ █▀█ █▄▀
-- █░▀█ █▄█ █▀▄ █▄▀   █▄▀ █▀█ █▀▄ █░█

local gfs      = require("gears.filesystem")
local colors   = {}
local override = {}
local switcher = {}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/colorschemes/nord/dark.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

colors.accents = {
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

colors.bg_0 = "#222732"
colors.bg_1 = "#262c38"
colors.bg_2 = "#2b313e"
colors.bg_3 = "#2f3644"
colors.bg_4 = "#343b4a"
colors.bg_5 = "#394050"
colors.bg_6 = "#3d4657"
colors.bg_7 = "#424b5d"
colors.bg_8 = "#475063"
colors.bg_9 = "#4c566a"


colors.fg_0 = "#d8dee9"
colors.fg_1 = "#8897b3"
colors.fg_2 = "#647594"

-- Gradient from primary (main accent) color to bg_2
-- Use https://colordesigner.io/gradient-generator (with mode HSL)
colors.primary_0 = "#5e81ac"
colors.primary_1 = "#506c91"
colors.primary_2 = "#455874"
colors.primary_3 = "#384458"
colors.primary_4 = "#2a313d"

colors.red     = "#bf616a"
colors.green   = "#a3be8c"
colors.yellow  = "#ebcb8b"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 

override.wibar_occupied = colors.fg_0

return {
  colors    = colors,
  switcher  = switcher,
  override  = override,
  wall_path = wall_path,
}
