
-- ▀█▀ ▄▀█ █▄▄ █░░ █▀▀ ▀█▀    █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ █▄▄ ██▄ ░█░    ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

-- Configure settings for touchscreen devices.

return {

  tablet_mode_enabled = true,

  -- The PIN lockscreen is a replacement for a display manager because I use
  -- my tablet without a keyboard and I can't find a display manager with a
  -- touchscreen pin login.
  -- This lockscreen is definitely not bulletproof and it isn't meant to be - it's
  -- just a rudimentary safeguard.
  lock = {

    enable_lockscreen_on_start = false,

    -- This must be a string and must be numeric.
    -- This can be any length you want.
    pin = "0000",

  },

}
