-- █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀ 
-- █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░ 

local awful = require("awful")
local bling = require("modules.bling")

-- custom layouts
local mstab = bling.layout.mstab
local deck = bling.layout.deck

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    mstab,
    awful.layout.suit.floating,
    deck,
    awful.layout.suit.max,
  })
end)
