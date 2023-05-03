
-- █▀▄ ▄▀█ █▀ █░█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▀ █▀█ ▄█ █▀█    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Unfinished. Decided not to use it but leaving here anyways.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gtable = require("gears.table")

local popup = {}

local function worker(user_args)
  local args = {
    title = "Title",
    subtitle = "Subtitle",
  }
  gtable.crush(args, user_args)

  popup = wibox.widget({
    {
      {
        ui.textbox({
          text  = args.title,
          font  = beautiful.font_med_m,
          color = beautiful.primary[700]
        }),
        ui.textbox({
          text  = args.subtitle,
          font  = beautiful.font_reg_s,
          color = beautiful.primary[600]
        }),
        layout = wibox.layout.fixed.vertical,
      },
      right  = dpi(25),
      left   = dpi(20),
      top    = dpi(15),
      bottom = dpi(15),
      widget = wibox.container.margin,
    },
    visible = false,
    bg = beautiful.primary[100],
    border_width = dpi(2),
    border_color = beautiful.primary[500],
    shape  = ui.rrect(),
    widget = wibox.container.background,
  })

  function popup:trigger()
  end

end

return setmetatable(popup, { __call = function(_, ...) return worker(...) end })
