
-- █▀█ █▀█ █▀ █▀▀    █▀█ █ █▄░█ █▀▀    █▀▄ ▄▀█ █░█░█ █▄░█ 
-- █▀▄ █▄█ ▄█ ██▄    █▀▀ █ █░▀█ ██▄    █▄▀ █▀█ ▀▄▀▄▀ █░▀█ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

local theme = {
  type = "light",
  wall = awesome_cfg .. "theme/colorschemes/rose-pine/ghibli.png",

  primary = {
    base = "#b4637a",
  },
  neutral = {
    light = "#575279",
    base  = "#cecacd",
    dark  = "#f4ede8",
  },
  colors = {
    red    = "#b4637a",
    green  = "#56949f",
    yellow = "#ea9d34",
  },
  accents = {
    "#b4637a",
    "#ea9d34",
    "#d7827e",
    "#286983",
    "#56949f",
    "#907aa9",
  },

  integrations = {
    kitty = "Rosé Pine Dawn",
    nvim  = { "rose-pine", "light" } ,
  }
}

return theme
