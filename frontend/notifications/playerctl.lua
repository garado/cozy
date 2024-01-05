
-- █▀█ █░░ ▄▀█ █▄█ █▀▀ █▀█ █▀▀ ▀█▀ █░░
-- █▀▀ █▄▄ █▀█ ░█░ ██▄ █▀▄ █▄▄ ░█░ █▄▄

local naughty = require("naughty")
local bling = require("modules.bling")
local strutil = require("utils.string")

local music_notif

local playerctl = bling.signal.playerctl.lib({
  update_on_activity = true,
  player = { "spotify", "mpd", "%any" },
  debounce_delay = 1,
})

playerctl:connect_signal("metadata", function(_, title, artist, album_path, _, new, _)
  if music_notif then music_notif:destroy() end

  if new then
    music_notif = naughty.notification {
      app_name = "Music",
      title = strutil.fix_html(title),
      text  = strutil.fix_html(artist),
      image = album_path,
    }
  end
end)
