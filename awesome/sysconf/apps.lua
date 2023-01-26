
-- ▄▀█ █▀█ █▀█ █░░ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▀▀ █▀▀ █▄▄ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

-- Default applications.

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

	--- List of binaries/shell scripts that will execute for a certain task
	utils = {
    bluetooth     = utils_dir .. "apps/rofi_bluetooth",
    app_launcher  = utils_dir .. "apps/rofi_app_launcher",
	},
}
