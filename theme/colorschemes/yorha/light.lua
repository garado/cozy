-- █▄█ █▀█ █▀█ █░█ ▄▀█    █░░ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █▀▄ █▀█ █▀█    █▄▄ █ █▄█ █▀█ ░█░

local cfg = require("gears.filesystem").get_configuration_dir()
local path = cfg .. ((...):match("(.-)[^%.]+$")):gsub("%.", "/") -- path to this file's dir

local theme = {
  type = "light",
  wall = path .. "wall_dark",
  accent_image = path .. "accent_light",

  yorha = "#cd664d",

  primary = {
    base = "#8b7f65",
  },
  neutral = {
    light = "#494949",
    base  = "#a6a492",
    dark  = "#d9d5ba",
  },
  colors = {
    red    = "#825b69",
    green  = "#69825b",
    yellow = "#82755b",
  },
  accents = {
    "#8b7f66",
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
