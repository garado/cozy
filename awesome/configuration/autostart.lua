
-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░

local awful = require("awful")
local filesystem = require("gears.filesystem")

local function autostart()
  awful.spawn.once("picom", false)
  awful.spawn.once("~/init_monitors.sh")
end

autostart()
