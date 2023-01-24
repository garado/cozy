
-- ▄▀█ █░█ ▀█▀ █▀█ █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- █▀█ █▄█ ░█░ █▄█ ▄█ ░█░ █▀█ █▀▄ ░█░

-- Configure apps that run on startup

local awful = require("awful")
local config = require("config")

awful.spawn.once("picom", false)

if config.tabletmode then
  awful.spawn.once("touchegg", false)
  print('starting touchegg')
end
