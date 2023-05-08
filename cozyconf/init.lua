
-- █▀▀ █▀█ ▀█ █▄█ █▀▀ █▀█ █▄░█ █▀▀ 
-- █▄▄ █▄█ █▄ ░█░ █▄▄ █▄█ █░▀█ █▀░ 

-- The various files in this folder are used to configure Cozy.

local gtable = require("gears.table")

local config = {}

gtable.crush(config, require(... .. ".ui"))
gtable.crush(config, require(... .. ".dash"))

return config
