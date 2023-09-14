-- █░░ █ █▀ ▀█▀    █ ▀█▀ █▀▀ █▀▄▀█
-- █▄▄ █ ▄█ ░█░    █ ░█░ ██▄ █░▀░█

local wibox = require("wibox")
local ui = require("utils.ui")
local dpi = ui.dpi
local beautiful = require("beautiful")

local _ = {}

local function worker(args)
  local item = wibox.widget({
    {
      ui.textbox({
        text = args.text,
      }),
      left = dpi(10),
      top = dpi(3),
      bottom = dpi(3),
      widget = wibox.container.margin,
    },
    forced_width = dpi(100),
    forced_height = dpi(30),
    bg = beautiful.neutral[500],
    widget = wibox.container.background,
  })

  local ind = require("frontend.widget.yorha.list.indicator")({
    height = dpi(15),
    width = dpi(25),
  })

  local widget = wibox.widget({
    wibox.container.place(ind),
    wibox.container.place(item),
    spacing = dpi(5),
    layout = wibox.layout.fixed.horizontal,
  })

  return widget
end

return setmetatable(_, { __call = function(_, ...) return worker(...) end })
