

-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ ▀    █▀▀ █░█ ░░█ █ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ▄    █▀░ █▄█ █▄█ █ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

local theme = {
  type = "dark",
  wall = awesome_cfg .. "theme/colorschemes/mountain/color_wp",

  primary = {
    base = "#7d6a4f",
  },
  neutral = {
    dark  = "#0f0f0f",
    base  = "#2c2c2c",
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
    "#c4c19e",
    "#c49ea0",
    "#ceb188",
    "#9ec3c4",
    "#9ec49f",
    "#a5b4cb",
  },
}

return theme
