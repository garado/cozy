local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utils/"

return {
	--- Default Applications
	default = {
		terminal = "alacritty",
		web_browser = "firefox",
		file_manager = "thunar",
	},

	--- List of binaries/shell scripts that will execute for a certain task
	utils = {
    bluetooth = utils_dir .. "apps/rofi_bluetooth",
    tmux_pane_presets = utils_dir .. "apps/rofi_tmux_pane_presets",
    app_launcher = utils_dir .. "apps/rofi_app_launcher",
	},
}
