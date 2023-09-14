

-- █░░ █ █▄░█ █▀▀    █▀▀ █▀█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ █▀▀ █▀█ 
-- █▄▄ █ █░▀█ ██▄ ▄▄ █▄▄ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")

local linecont = {}

local function worker(args)

  local line = wibox.widget({
    {
      thickness = dpi(2),
      color = beautiful.neutral[600],
      forced_height = dpi(5),
      widget = wibox.widget.separator,
    },
    top    = dpi(8),
    bottom = dpi(8),
    left   = dpi(10),
    right  = dpi(10),
    widget = wibox.container.margin,
  })

  return wibox.widget({
    {
      line,
      { -- widget
        args.widget,
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      line,
      layout  = wibox.layout.fixed.vertical,
    },
    forced_height = args.height or nil,
    forced_width = args.width or nil,
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  })
end

return setmetatable(linecont, { __call = function(_, ...) return worker(...) end })
