local awful = require("awful")
local bling = require("modules.bling")

-- custom layouts
local mstab = bling.layout.mstab

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    mstab,
  })
end)
