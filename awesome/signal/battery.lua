
-- █▄▄ ▄▀█ ▀█▀ ▀█▀ █▀▀ █▀█ █▄█
-- █▄█ █▀█ ░█░ ░█░ ██▄ █▀▄ ░█░

-- Credit: - https://github.com/Aire-One/awesome-battery_widget
--         - @rxyhn

local upower_widget = require("modules.upower")
local battery_listener = upower_widget({
	device_path = "/org/freedesktop/UPower/devices/battery_BAT0",
	instant_update = true,
})

battery_listener:connect_signal("upower::update", function(_, device)
	awesome.emit_signal("signal::battery", device.percentage, device.state)
end)
