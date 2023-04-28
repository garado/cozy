
-- █▀█ █▀█ █▀▀ █░█ █ █▀▀ █░█░█ 
-- █▀▀ █▀▄ ██▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local config = require("cozyconf")

local scale = 0.3

-- Test primary preview.

local _primary_btn_popup = wibox.widget({
  {
    {
      ui.textbox({
        text = "This is Primary 700.",
        align = "left",
        font = beautiful.font_med_m,
        color = beautiful.primary[700]
      }),
      ui.textbox({
        text = "This is Pri 600. Background is Pri 100. Border is Pri 500.",
        align = "left",
        font = beautiful.font_reg_s,
        color = beautiful.primary[600]
      }),
      layout = wibox.layout.fixed.vertical,
    },
    right = dpi(25),
    left  = dpi(20),
    top   = dpi(15),
    bottom = dpi(15),
    widget = wibox.container.margin,
  },
  bg = beautiful.primary[100],
  border_width = dpi(2),
  border_color = beautiful.primary[500],
  shape = ui.rrect(),
  widget = wibox.container.background,
})

local primary_preview = wibox.widget({
  ui.textbox({
    text = "Primary",
    align = "left",
    font = beautiful.font_bold_s,
  }),
  {
    _primary_btn_popup,
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})


-- Test neutral shades.

local _neutral_card = wibox.widget({
  {
    {
      {
        ui.textbox({
          text = "Neu 300",
          font = beautiful.font_reg_s,
          align = "left",
          color = beautiful.neutral[300],
        }),
        layout = wibox.layout.align.horizontal,
      },
      ui.textbox({
        text = "Neu $100.00",
        align = "left",
        font = beautiful.font_reg_l,
        color = beautiful.neutral[100],
      }),
      ui.textbox({
        text = "Background is Neu 800",
        align = "left",
        color = beautiful.neutral[300],
      }),
      spacing = dpi(7),
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(15),
    widget = wibox.container.margin,
  },
  bg = beautiful.neutral[800],
  shape = ui.rrect(),
  widget = wibox.container.background,
})


local neutral_preview = wibox.widget({
  ui.textbox({
    text = "Neutrals",
    align = "left",
    font = beautiful.font_bold_s,
  }),
  _neutral_card,
  spacing = dpi(10),
  forced_width = dpi(200),
  layout = wibox.layout.fixed.vertical,
})

-- Test red, green, yellow shades.

local function _shade(shade)
  local text
  if shade == "red" then
    text = "Color 500"
  elseif shade == "green" then
    text = " on top of "
  elseif shade == "yellow" then
    text = "Color 100"
  end

  return wibox.widget({
    {
      ui.textbox({
        text = text,
        font = beautiful.font_bold_xs,
        color = beautiful[shade][500],
      }),
      margins = dpi(10),
      widget  = wibox.container.margin,
    },
    bg = beautiful[shade][100],
    shape = ui.rrect(),
    forced_width = dpi(80),
    widget = wibox.container.background,
  })
end

local shade_preview = wibox.widget({
  ui.textbox({
    text  = "Accents",
    font  = beautiful.font_bold_s,
    align = "left",
  }),
  {
    _shade("red"),
    _shade("green"),
    _shade("yellow"),
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})



-- Test random accent colors.

local _accent_preview = function(clr)
  local preview = wibox.widget({
    spacing = dpi(8),
    layout  = wibox.layout.fixed.vertical,
    -----
    _add = function(self, c, i)
      self:add(ui.textbox({
        text  = "Random " .. tostring(i) .. " on Neutral "..tostring(clr)..".",
        color = c,
      }))
    end,
    init = function(self)
      for i = 1, #beautiful.accents do
        self:_add(beautiful.accents[i], i)
      end
    end
  })
  preview:init()
  return wibox.widget({
    {
      preview,
      margins = dpi(20),
      widget  = wibox.container.margin,
    },
    bg = beautiful.neutral[clr],
    widget = wibox.container.background,
  })
end

local accent_preview = wibox.widget({
  ui.textbox({
    text  = "Random accents",
    font  = beautiful.font_bold_s,
    align = "left",
  }),
  {
    _accent_preview(800),
    _accent_preview(900),
    forced_width = dpi(500),
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(10),
  forced_width = dpi(800),
  layout  = wibox.layout.fixed.vertical,
})

return function()
  return wibox.widget({
    primary_preview,
    neutral_preview,
    shade_preview,
    accent_preview,
    spacing = dpi(20),
    layout  = wibox.layout.fixed.vertical,
  })
end

