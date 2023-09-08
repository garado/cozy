
-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░

-- Configure apps that run on startup

local awful = require("awful")

-- BUG: When testing with awmtt, this breaks the test instance
-- awful.spawn.easy_async_with_shell("picom", function() end)
