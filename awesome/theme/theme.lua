-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")

-- get user's color scheme
local theme_name = require("user_variables").theme
local theme = require("theme/colorschemes/" .. theme_name)

-- theme-agnostic settings
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")
theme.transparent = "#ffffff00"

return theme
