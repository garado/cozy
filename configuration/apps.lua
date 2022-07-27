local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
	--- Default Applications
	default = {
		terminal = "alacritty",
		web_browser = "firefox",
		file_manager = "thunar",
		app_launcher = "$HOME/.config/rofi/launcher.sh",
    bluetooth = "$HOME/bin/rofi-bluetooth",
    tmux_presets = "$HOME/bin/rofi_tmux_presets",
	},

	--- List of binaries/shell scripts that will execute for a certain task
	utils = {
    tmux_launcher = "$HOME/bin/rofi_tmux_presets"
	},
}
