
-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░

-- Configure apps that run on startup

local awful = require("awful")

awful.spawn.easy_async_with_shell("picom", false)
