
-- ▄▀█ █▀▀ █▀▀ █▀█ █░█ █▄░█ ▀█▀ █▀ 
-- █▀█ █▄▄ █▄▄ █▄█ █▄█ █░▀█ ░█░ ▄█ 

-- Shows cards for checking/savings/cash balances.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local CHECKING = 1
local SAVINGS  = 2
local CASH     = 3

-- @param ledger_enum 
local function gen_account(ledger_enum)
  return wibox.widget({
    {
      {
        {
          ui.textbox({
            text = "Checking",
            align = "left",
            color = beautiful.neutral[200],
          }),
          nil,
          {
            {
              ui.textbox({
                text = "20%",
                align = "center",
                font = beautiful.font_bold_xs,
                color = beautiful.red[500],
              }),
              top     = dpi(5),
              bottom  = dpi(5),
              left    = dpi(8),
              right   = dpi(8),
              widget  = wibox.container.margin,
            },
            shape = ui.rrect(),
            bg = beautiful.red[100],
            widget = wibox.container.background,
          },
          layout = wibox.layout.align.horizontal,
        },
        ui.textbox({
          text  = "$3021.00",
          align = "left",
          font  = beautiful.font_light_xl,
          color = beautiful.neutral[100],
        }),
        ui.textbox({
          text  = "Line graph goes here",
          align = "left",
          color = beautiful.neutral[200],
        }),
        spacing = dpi(12),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(18),
      widget  = wibox.container.margin,
    },
    forced_width = dpi(260),
    bg     = beautiful.neutral[800],
    shape  = ui.rrect(),
    widget = wibox.container.background,
  })
end

return function()
  return {
    gen_account(CHECKING),
    gen_account(SAVINGS),
  }
end
