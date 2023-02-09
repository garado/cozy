
-- ▄▀█ █▀█ █▀█    █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- █▀█ █▀▀ █▀▀    ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

-- Configure Cozy's custom applications.

local gfs = require("gears.filesystem")
local CWD = gfs.get_configuration_dir() .. "cozyconf/"

return {

  -- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀ █▀ 
  -- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█ ▄█ 

  bookmarks = {
    -- The path to the json file to read bookmarks from.
    path = CWD .. "samplefiles/bookmarks.json",

    -- The category to show on startup.
    default_category = "",

    -- If quicklinks popup should close after opening a new link.
    close_after_opening_link = false,
  },


  -- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
  -- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 

  control = {

    -- Latitude and longitude for nightshift
    nightshift = {
      lat  = 32,
      long = -122,
    }
  },

}
