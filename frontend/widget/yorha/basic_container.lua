
-- █▄▄ ▄▀█ █▀ █ █▀▀    █▀▀ █▀█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ █▀▀ █▀█ 
-- █▄█ █▀█ ▄█ █ █▄▄    █▄▄ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")

local header = {}

local function worker(args)
  return wibox.widget({
    {
      { -- Header
        {
          ui.textbox({
            text = args.text,
            font = beautiful.font_reg_s,
            color = beautiful.neutral[900],
            height = dpi(22),
          }),
          margins = dpi(5),
          widget = wibox.container.margin,
        },
        bg = beautiful.neutral[100],
        widget = wibox.container.background,
      },
      {
        args.widget,
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      layout  = wibox.layout.fixed.vertical,
    },
    forced_height = args.height or nil,
    forced_width = args.height or nil,
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  })
end

return setmetatable(header, { __call = function(_, ...) return worker(...) end })
