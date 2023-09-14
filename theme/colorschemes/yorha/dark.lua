
-- █▄█ █▀█ █▀█ █░█ ▄▀█    █▀▄ ▄▀█ █▀█ █▄▀ 
-- ░█░ █▄█ █▀▄ █▀█ █▀█    █▄▀ █▀█ █▀▄ █░█ 

local cfg = require("gears.filesystem").get_configuration_dir()
local path = cfg .. ((...):match("(.-)[^%.]+$")):gsub("%.", "/") -- path to this file's dir

local theme = {
  type = "dark",
  wall = path .. "wall_dark",
  accent_image = path .. "wall_dark",

  primary = {
    base = "#bdb3a0",
  },
  neutral = {
    dark  = "#494949",
    base  = "#696862",
    light = "#c9c5ad",
  },
  colors = {
    red    = "#825b69",
    green  = "#69825b",
    yellow = "#82755b",
  },
  accents = {
    "#8fbcbb",
    "#88c0d0",
    "#81a1c1",
    "#5e81ab",
    "#bf616b",
    "#d08770",
    "#ebcb8c",
    "#a3be8d",
    "#b48ead",
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
    kitty = "Nostalgia Light",
    nvim  = "nostalgia",
  }
}

return theme
