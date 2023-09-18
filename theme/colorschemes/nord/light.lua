
-- █▄░█ █▀█ █▀█ █▀▄    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▀ █▀█ █▀▄ █░█ 

local cfg = require("gears.filesystem").get_configuration_dir()
local path = cfg .. ((...):match("(.-)[^%.]+$")):gsub("%.", "/") -- path to this file's dir

return {
  type = "dark",
  wall = path .. "wallpaper",
  accent_image = path .. "accent_image",

  primary = {
    base = "#5e81ac",
  },
  neutral = {
    dark  = "#1f242f",
    base  = "#465064",
    light = "#e5e9f0",
  },
  colors = {
    red    = "#bf616a",
    green  = "#a3be8c",
    yellow = "#ebcb8b",
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
    kitty = "Nord",
    nvim  = "onenord_light",
  }
}
