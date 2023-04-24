
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

-- Theme manager

local wibox = require("wibox")
local area  = require("modules.keynav.area")
local beautiful = require("beautiful")
local colorize  = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local score = require("core.cozy.settings")

local settings = wibox.widget({

})

return function()
  return settings --, nav_settings
end
