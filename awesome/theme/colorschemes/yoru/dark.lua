
-- █▄█ █▀█ █▀█ █░█ 
-- ░█░ █▄█ █▀▄ █▄█ 

local gfs = require("gears.filesystem")
local colors   = {}
local override = {}
local switcher = {}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/colorschemes/yoru/wp.jpg"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

colors.accents = {
  "#df5b61",
  "#78b892",
  "#5a84bc",
  "#6791c9",
  "#f1cf8a",
  "#ac78d0",
  "#70b8ca",
  "#e89982",
}
-- 
colors.bg_0  = "#101213"
colors.bg_1  = "#0c0e0f"
colors.bg_2  = "#121415"
colors.bg_3  = "#161819"
colors.bg_4  = "#1f2122"
colors.bg_5  = "#27292a" -- edit after here
colors.bg_6  = "#27292a"
colors.bg_7  = "#27292a"
colors.bg_8  = "#27292a"
colors.bg_9  = "#27292a"

colors.fg_0 = "#edeff0"
colors.fg_1 = "#363c49"
colors.fg_2 = "#666c79"

colors.red         = "#df5b61"
colors.green       = "#78b892"
colors.yellow      = "#f1cf8a"
colors.purple      = "#ac78d0"
colors.transparent = "#ffffff00"
-- 
-- -- https://colordesigner.io/gradient-generator
-- colorscheme.colors.gradient = {
colors.primary_0 = "#6791c9"
colors.primary_1 = "#466f9f"
colors.primary_2 = "#2f4e6f"
colors.primary_3 = "#1d2d3f"
colors.primary_4 = "#0c0e0f"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 

override.wibar_focused  = "#6791c9"
override.wibar_occupied = "#edeff0"
override.wibar_empty    = "#363c49"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

switcher.kitty    = "Yoru"
switcher.nvchad   = "yoru"
switcher.rofi     = "yoru"
switcher.firefox  = "yoru"
switcher.start    = "yoru"

return {
  colors    = colors,
  switcher  = switcher,
  override  = override,
  wall_path = wall_path,
}
