
-- ▄▀█ █▀█ █▀█    █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- █▀█ █▀▀ █▀▀    ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

-- Configure Cozy's custom applications.

local gfs = require("gears.filesystem")

-- I gotta find a better way to find this
local CWD = gfs.get_configuration_dir() .. (...):match("(.-)[^%.]+$"):sub(1, -2)

return {

  bookmarks = {
    path = CWD .. "/samplefiles/bookmarks.json"
  }

}
