require(... .. ".autostart")
require(... .. ".desktop")
require(... .. ".keys")
require(... .. ".layout")
require(... .. ".ruled")
require(... .. ".tags")
require(... .. ".restore")

-- idk where to put this
-- Only show border when there's more than 1 window on screen
local beautiful = require("beautiful")
screen.connect_signal("arrange", function (s)
  local only_one = #s.tiled_clients == 1
  for _, c in pairs(s.clients) do
    if only_one and not c.floating or c.maximized then
      c.border_width = 0
    else c.border_width = beautiful.border_width
    end
  end
end)
