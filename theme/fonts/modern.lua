
-- █▀▄▀█ █▀█ █▀▄ █▀▀ █▀█ █▄░█ 
-- █░▀░█ █▄█ █▄▀ ██▄ █▀▄ █░▀█ 

local _font = {}

local dpi = require("utils.ui").dpi

local type =      "Circular Std "
_font.font_name = "Circular Std "

local weights = {
  light = "Light ",
  reg   = "Regular ",
  med   = "Medium ",
  bold  = "Bold ",
}

_font.font_sizes = {
  xs =  dpi(9),
  s  =  dpi(11),
  m  =  dpi(14),
  l  =  dpi(22),
  xl =  dpi(28),
  xxl = dpi(35),
}

-- Generate font pairings
for w_name, w_val in pairs(weights) do
  for s_name, s_val in pairs(_font.font_sizes) do
    local fval  = type .. w_val .. s_val
    local fname = 'font_' .. w_name .. '_' .. s_name
    _font[fname] = fval
  end
end

------

local alt_type = "Fira Code "
_font.alt_font_name = "Fira Code "

local alt_weights = {
  reg   = "Regular ",
  med   = "Medium ",
  bold  = "Bold ",
}

local alt_sizes = {
  xs = 9,
  s  = 12,
  m  = 14,
  l  = 22,
  xl = 28,
}

-- Generate font pairings
for w_name, w_val in pairs(alt_weights) do
  for s_name, s_val in pairs(alt_sizes) do
    local fval  = alt_type .. w_val .. s_val
    local fname = 'altfont_' .. w_name .. '_' .. s_name
    _font[fname] = fval
  end
end

return _font
