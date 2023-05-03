
-- ▄▀█ █▀█ █▀█ █░░ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▀▀ █▀▀ █▄▄ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utils/"

return {
	--- Default Applications
	default = {
		terminal      = "kitty",
		web_browser   = "firefox",
		file_manager  = "thunar",
	},
}
