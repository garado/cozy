
-- █▄░█ █▀█ █▀█ █▀▄    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ █▀▄ █▄▀    █▄▄ █ █▄█ █▀█ ░█░ 

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

local theme = {
  type = "light",
  wall = awesome_cfg .. "theme/colorschemes/nord/light_wp",

  primary = {
    base = "#5e81ac",
  },
  neutral = {
    light = "#2e3440",
    base  = "#76839d",
    dark  = "#eceff4",
  },
  colors = {
    red    = "#b44953",
    green  = "#6b8c4f",
    yellow = "#dcad50",
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
    kitty   = "Nord Light",
    nvim  = { "nord", "light" },
  }
}

return theme
