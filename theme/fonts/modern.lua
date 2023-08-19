
-- █▀▄▀█ █▀█ █▀▄ █▀▀ █▀█ █▄░█ 
-- █░▀░█ █▄█ █▄▀ ██▄ █▀▄ █░▀█ 

local dpi = require("utils.ui").dpi

return {
  font_name = "Circular Std ",
  font_weights = {
    light = "Light ",
    reg   = "Regular ",
    med   = "Medium ",
    bold  = "Bold ",
  },
  font_sizes = {
    xs =  dpi(9),
    s  =  dpi(11),
    sm =  dpi(13),
    m  =  dpi(16),
    l  =  dpi(22),
    xl =  dpi(28),
    xxl = dpi(35),
  },

  alt_font_name = "Fira Code ",
  alt_font_weights = {
    reg   = "Regular ",
    med   = "Medium ",
    bold  = "Bold ",
  },
  alt_font_sizes = {
    xs = 9,
    s  = 12,
    m  = 14,
    l  = 22,
    xl = 28,
  }
}
