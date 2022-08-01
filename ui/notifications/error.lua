
-- █▀▀ █▀█ █▀█ █▀█ █▀█   █▄░█ █▀█ ▀█▀ █ █▀▀ █▀
-- ██▄ █▀▄ █▀▄ █▄█ █▀▄   █░▀█ █▄█ ░█░ █ █▀░ ▄█

local naughty = require("naughty")

-- This runs if there's an error with the config somewhere
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification({
    urgency = "critical",
    app_name = "Awesome",
    title = "you fucked up",
    font = "Comic Sans",
    fg = "#a8329b",
    message = message,
    ontop = true,
  })
end)
