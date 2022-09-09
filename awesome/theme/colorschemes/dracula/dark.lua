
-- █▀▄ █▀█ ▄▀█ █▀▀ █░█ █░░ ▄▀█
-- █▄▀ █▀▄ █▀█ █▄▄ █▄█ █▄▄ █▀█

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local math = math

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
local awesome_cfg = gfs.get_configuration_dir()
local wall_path = awesome_cfg .. "theme/assets/walls/dracula.png"
theme.wallpaper = gears.surface.load_uncached(wall_path)

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
theme.dark    = "#191a21" -- custom
theme.custom2 = "#1e1f29" -- custom
theme.bg      = "#282a36"
theme.bg2     = "#343746" -- custom
theme.cl      = "#44475a"	
theme.fg      = "#f8f8f2"	
theme.comment = "#6272a4"	
theme.cyan    = "#8be9fd"	
theme.green   = "#50fa7b"	
theme.orange  = "#ffb86c"	
theme.pink    = "#ff79c6"	
theme.purple  = "#bd93f9"	
theme.red     = "#ff5555"	
theme.yellow  = "#f1fa8c"

theme.transparent = "#ffffff00"

theme.accents = {
  theme.comment,
  theme.cyan,
  theme.green,
  theme.orange,
  theme.pink,
  theme.purple,
  theme.red,
  theme.yellow,
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide
-- background colors
theme.base          = theme.dark      -- dash, wibar
theme.crust         = theme.custom2   -- widget bg
theme.mantle        = theme.bg2       -- 
theme.surface0      = theme.bg        -- dash button bg 
theme.surface1      = theme.comment   --
theme.overlay0      = theme.cl        -- album art filters

-- typography
theme.fg            = theme.fg        -- main text
theme.subtitle      = theme.cl 
theme.subtext       = theme.cl
theme.main_accent   = theme.purple    -- primary accent color

-- changing colors up to this point should be all you need
-- to change the entire color scheme.
-- but if you want even more fine-grained color customization, 
-- you can control the colors for almost every single UI element 
-- in theme.lua.

-- settings for theme switcher
theme.kitty = "Dracula"
theme.nvim  = "chadracula"
theme.gtk   = "Dracula"

return theme
