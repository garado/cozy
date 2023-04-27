
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄ 

local cozy    = require("backend.state.cozy")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local colorscheme = require("theme.colorschemes.nord.newdark")
local color = require("modules.color")

local theme = {}

-- Generate primary colors
local _primary_base = colorscheme.primary.base
local primary_base = color.color { hex = _primary_base }

local primaries = {}
for i = 1, 4, 1 do
  local newcolor = primary_base + "1l"
  print('Newcolor: ' .. primary_base.hex)
end

return theme
