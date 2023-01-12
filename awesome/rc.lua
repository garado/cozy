
-- █▀▀ █▀█ ▀█ █▄█    ▄▀█ █░█░█ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀    █▀▀ █▀█ █▄░█ █▀▀ █ █▀▀ 
-- █▄▄ █▄█ █▄ ░█░    █▀█ ▀▄▀▄▀ ██▄ ▄█ █▄█ █░▀░█ ██▄    █▄▄ █▄█ █░▀█ █▀░ █ █▄█ 

-- by @garado
-- https://github.com/garado/cozy

pcall(require, "luarocks.loader")

local gears     = require("gears")
local beautiful = require("beautiful")

local theme_dir = gears.filesystem.get_configuration_dir() .. "theme/"
beautiful.init(theme_dir .. "theme.lua")

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({
	timeout = 300,
	autostart = true,
	call_now = true,
	callback = function()
		collectgarbage("collect")
	end,
})

require("configuration")
require("modules")
require("ui")
require("helpers")
