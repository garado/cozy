
-- █▄░█ █▀█ █▀ ▀█▀ ▄▀█ █░░ █▀▀ █ ▄▀█ 
-- █░▀█ █▄█ ▄█ ░█░ █▀█ █▄▄ █▄█ █ █▀█ 
-- https://github.com/mitchweaver/color-nostalgia

local gfs = require("gears.filesystem")
local colorscheme = {
  colors = {},
  override = {},
  switcher = {},
  wall_path = nil,
}

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
colorscheme.wall_path = awesome_cfg .. "theme/assets/walls/nostalgia.png"

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
colorscheme.colors.accents = {
  "#825b69",
  "#69825b",
  "#82755b",
  "#5b6982",
  "#755b82",
  "#5b8275",
  "#494949",
  "#333333",
  "#9f838d",
  "#9aad90",
  "#bdb3a0",
  "#7484a2",
  "#a390ad",
  "#90ada3",
  "#494847",
}

colorscheme.colors.bg_d0   = "#d9d5ba"
colorscheme.colors.bg      = "#d9d5ba"
colorscheme.colors.bg_l0   = "#c5c1a6"
colorscheme.colors.bg_l1   = "#bbb79c"
colorscheme.colors.bg_l2   = "#a7a388"
colorscheme.colors.bg_l3   = "#938f74"
colorscheme.colors.fg      = "#444444"
colorscheme.colors.fg_sub  = "#808080"
colorscheme.colors.fg_alt  = "#949494"

colorscheme.colors.main_accent = "#5b8275"
colorscheme.colors.red         = "#825b69"
colorscheme.colors.green       = "#8a9d89"
colorscheme.colors.yellow      = "#d9d5ba"
colorscheme.colors.transparent = "#ffffff00"

-- █▀█ █░█ █▀▀ █▀█ █▀█ █ █▀▄ █▀▀ 
-- █▄█ ▀▄▀ ██▄ █▀▄ █▀▄ █ █▄▀ ██▄ 
-- colorscheme.override.wibar_occupied = "#d8dee9"

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
colorscheme.switcher.kitty   = "Nostalgia Light"
colorscheme.switcher.nvchad  = "nostalgia_light"
-- colorscheme.switcher.gtk     = "Nordic"
-- colorscheme.switcher.zathura = "nord_dark"

return colorscheme

-- ! ----------------------------------------------------
-- !
-- ! color-nostalgia
-- !
-- ! https://github.com/mitchweaver/color-nostalgia
-- !
-- ! ----------------------------------------------------
-- 
-- ! ====== Main Colors ========
-- *foreground:        #444444
-- *.foreground:       #444444
-- *background:        #d9d5ba
-- *.background:       #d9d5ba
-- 
-- *.color0: #d9d5ba
-- *color0:  #d9d5ba
-- *.color1: #825b69
-- *color1:  #825b69
-- *.color2: #69825b
-- *color2:  #69825b
-- *.color3: #82755b
-- *color3:  #82755b
-- *.color4: #5b6982
-- *color4:  #5b6982
-- *.color5: #755b82
-- *color5:  #755b82
-- *.color6: #5b8275
-- *color6:  #5b8275
-- *.color7: #494949
-- *color7:  #494949
-- *.color8: #333333
-- *color8:  #333333
-- *.color9: #bda0aa
-- *color9:  #bda0aa
-- *.color10: #aabda0
-- *color10:  #aabda0
-- *.color11: #bdb3a0
-- *color11:  #bdb3a0
-- *.color12: #7484a2
-- *color12:  #7484a2
-- *.color13: #b3a0bd
-- *color13:  #b3a0bd
-- *.color14: #a0bdb3
-- *color14:  #a0bdb3
-- *.color15: #494847
-- *color15:  #494847
-- *.color66: #211f14
-- *color66:  #211f14
-- 
-- ! ======== Program Specific ========
-- emacs*foreground:   #444444
-- URxvt*foreground:   #444444
-- XTerm*foreground:   #444444
-- UXTerm*foreground:  #444444
-- emacs*background:   #d9d5ba
-- URxvt*background:   [100]#d9d5ba
-- XTerm*background:   #d9d5ba
-- UXTerm*background:  #d9d5ba
-- URxvt*cursorColor:  #444444
-- XTerm*cursorColor:  #444444
-- UXTerm*cursorColor: #444444
-- URxvt*borderColor:  [100]#444444
-- URxvt*depth: 32
