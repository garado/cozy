
-- █▄░█ █▀█ █▀█ █▀▄    █▀▄ ▄▀█ █▀█ █▄▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▀ █▀█ █▀▄ █░█ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

local theme = {
  type = "dark",
  wall = awesome_cfg .. "theme/colorschemes/nord/dark_wp",

  primary = {
    base = "#5e81ac",
  },
  neutral = {
    dark  = "#222732",
    base  = "#4c566a",
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
    "#5e81ac",
    "#bf616a",
    "#d08770",
    "#ebcb8b",
    "#a3be8c",
    "#b48ead",
  },

  integrations = {
    kitty = "Nord",
    nvim  = { "nord", "dark" },
  }
}

return theme
