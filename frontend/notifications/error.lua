
-- █▀▀ █▀█ █▀█ █▀█ █▀█   █▄░█ █▀█ ▀█▀ █ █▀▀ █▀
-- ██▄ █▀▄ █▀▄ █▄█ █▀▄   █░▀█ █▄█ ░█░ █ █▀░ ▄█

local naughty = require("naughty")

-- This runs if there's an error with the config somewhere
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification({
    urgency = "critical",
    app_name = "Awesome",
    title = "You fucked up",
    message = message,
    ontop = true,
    timeout = 0,
  })
end)
