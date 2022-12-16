
-- █▄░█ █▀█ █▀ ▀█▀ ▄▀█ █░░ █▀▀ █ ▄▀█    █░░ █ █▀▀ █░█ ▀█▀ 
-- █░▀█ █▄█ ▄█ ░█░ █▀█ █▄▄ █▄█ █ █▀█    █▄▄ █ █▄█ █▀█ ░█░ 

-- A neutral yet colorful theme that brings about an odd sense of nostalgia.
-- https://github.com/mitchweaver/color-nostalgia

local M = {}

M.base_30 = {
  white         = "#2c2c2c", -- done
  darker_black  = "#ccc9af", -- done
  black         = "#d9d5ba", -- done (nvim bg)
  black2        = "#c9c5aa", -- done
  one_bg        = "#cbc7ab", -- done
  one_bg2       = "#bbb79b", -- done 
  one_bg3       = "#afac8e", -- done
  grey          = "#a4a082", -- done
  grey_fg       = "#9c9a7a", -- done (comments)
  grey_fg2      = "#8c8a6a", -- done
  light_grey    = "#7d7b5b", -- done
  red           = "#926d63", -- done
  baby_pink     = "#765a49", -- done
  pink          = "#815b68", -- done
  line          = "#dcd9b0", -- done
  green         = "#69805a", -- done
  vibrant_green = "#526945", -- done
  nord_blue     = "#475266", -- done
  blue          = "#5a6882", -- done
  yellow        = "#c2a96f", -- done
  sun           = "#c8af75", -- done
  purple        = "#745a82", -- done
  dark_purple   = "#584362", -- done
  teal          = "#5d8076", -- done
  orange        = "#83755b", -- done
  cyan          = "#5a6882", -- done
  statusline_bg = "#ccc8ad", -- done
  lightbg       = "#bcb89d", -- done
  pmenu_bg      = "#5c8275", -- done
  folder_bg     = "#7484a2", -- done
}

M.base_16 = {
  base00 = "#d9d5ba", -- done
  base01 = "#cbc7ab", -- done
  base02 = "#bbb79b", -- done
  base03 = "#afac8e", -- done
  base04 = "#a4a082", -- done
  base05 = "#4c4c4c", -- done
  base06 = "#3e3e3e", -- done
  base07 = "#2c2c2c", -- done
  base08 = "#815b68", -- done
  base09 = "#765a49", -- done
  base0A = "#83755b", -- done
  base0B = "#69805a", -- done
  base0C = "#5d8076", -- done
  base0D = "#5a6882", -- done
  base0E = "#745a82", -- done
  base0F = "#926d63", -- done
}

vim.opt.bg = "light" -- this can be either dark or light

M = require("base46").override_theme(M, "atheme")

return M
