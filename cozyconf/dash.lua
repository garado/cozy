
local beautiful = require("beautiful")

return {

  -- █▀▄▀█ ▄▀█ █ █▄░█ 
  -- █░▀░█ █▀█ █ █░▀█ 

  -- The name to display on the main tab.
  name = "Alexis",

  -- Fun stuff to show beneath display name.
  titles = {
    "Mechromancer",
    "Open sourcerer",
    "Vim wizard",
    "CLI sorcerer",
    "Uses Arch, btw",
    "Linux enthusiast",
    "Dragonslayer",
    "Dragon hunter",
    "Outlander",
    "Oblivion walker",
  },

  distro_icon = "",

  -- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
  -- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

  -- Hours are in 24-hour format
  -- Days are 0-6, 0 == Sunday
  calendar = {
    start_hour = 8,
    end_hour   = 21, -- Shows through end hour
    start_day  = 0,  -- Not well-supported
    end_day    = 6,
    gridline_color = beautiful.neutral[800] or "#ffffff",
    nowline_color  = beautiful.red[300] or "#bf616a",
  }

}
