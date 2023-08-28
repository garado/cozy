
-- █▀█ █▀█ █▀ █▀▀    █▀█ █ █▄░█ █▀▀
-- █▀▄ █▄█ ▄█ ██▄    █▀▀ █ █░▀█ ██▄

local gfs = require("gears.filesystem")
local awesome_cfg = gfs.get_configuration_dir()

local theme = {
  type = "dark",
  wall = awesome_cfg .. "theme/colorschemes/rose-pine/main_wp",

  primary = {
    base = "#eb6f92",
  },
  neutral = {
    dark  = "#191724",
    base  = "#524f67",
    light = "#e0def4",
  },
  colors = {
    red    = "#eb6f92",
    green  = "#9ccfd8",
    yellow = "#f6c177",
  },
  accents = {
    "#eb6f92",
    "#f6c177",
    "#ebbcba",
    "#31748f",
    "#9ccfd8",
    "#c4a7e7",
  },

  integrations = {
    kitty = "Rosé Pine",
    nvim = { "rose-pine", "dark" },
  }
}

return theme
