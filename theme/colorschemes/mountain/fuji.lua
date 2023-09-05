
-- █▀▄▀█ █▀█ █░█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ ▀    █▀▀ █░█ ░░█ █ 
-- █░▀░█ █▄█ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ▄    █▀░ █▄█ █▄█ █ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

return {
  type = "dark",
  wall = awesome_cfg .. "theme/colorschemes/mountain/wp",
  accent_image = awesome_cfg .. "theme/colorschemes/mountain/nrofi",

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

  integrations = {
    kitty = "Mountain Fuji",
    nvim  = "mountain",
  }
}
