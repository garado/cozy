
-- █░█ █▄▄ ▄▀█ █▀█    █▀▀ █▀█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ █▀▀ █▀█ 
-- ▀▄▀ █▄█ █▀█ █▀▄    █▄▄ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ██▄ █▀▄ 

local wibox = require("wibox")
local dpi = require("utils.ui").dpi
local beautiful = require("beautiful")

local vbar_cont = {}

local function worker(widget)
  return wibox.widget({
    {
      require("frontend.widget.yorha.vbar")({ color = beautiful.neutral[700] }),
      top    = dpi(10),
      bottom = dpi(10),
      right = -dpi(10),
      widget = wibox.container.margin,
    },
    widget,
    spacing = dpi(5),
    layout = wibox.layout.fixed.horizontal,
  })
end

return setmetatable(vbar_cont, { __call = function(_, ...) return worker(...) end })
