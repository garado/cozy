
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ ▀    █▀▀ █░█ ░░█ █ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ▄    █▀░ █▄█ █▄█ █ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

return {
  type = "dark",
  wall = awesome_cfg .. "theme/colorschemes/mountain/wallpaper",
  accent_image = awesome_cfg .. "theme/colorschemes/mountain/accent_image",

  primary = {
    base = "#7d6a4f",
  },
  neutral = {
    dark  = "#0f0f0f",
    base  = "#222222",
    light = "#dedede",
  },
  colors = {
    red    = "#c49ea0",
    green  = "#89ab8a",
    yellow = "#c4c19e",
  },
  accents = {
    "#a39ec4",
    "#c49ec4",
    "#c4c19f",
    "#c49ea1",
    "#ceb188",
    "#9ec3c4",
    "#9ec49f",
    "#a5b4cb",
  },

  -- Pulsebar is a style where the bar background is transparent.
  -- Depending on which wallpaper you use, you may want to change the
  -- font color of the bar icons so that they're actually visible against
  -- the wallpaper.
  -- Options: dark light
  pulsebar_fg_l = "light",
  pulsebar_fg_m = "light",
  pulsebar_fg_r = "light",

  integrations = {
    kitty = "Mountain Fuji",
    nvim  = "mountain",
  }
}
