
-- ▄▀█ █▀█ █▀█    █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- █▀█ █▀▀ █▀▀    ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

-- Configure Cozy's custom applications.

local gfs = require("gears.filesystem")
local CWD = gfs.get_configuration_dir() .. "cozyconf/"

return {

  bookmarks = {
    path = CWD .. "samplefiles/bookmarks.json"
  }

}
