
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀█ █▀█ █▀▀ █░█ █ █▀▀ █░█░█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    █▀▀ █▀▄ ██▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Theme previewer.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local color = require("modules.color")
local clrutils = require("utils.color")
local config = require("cozyconf")

-- █░░ █▀▀ █▀▀ ▀█▀ █▀ █ █▀▄ █▀▀ 
-- █▄▄ ██▄ █▀░ ░█░ ▄█ █ █▄▀ ██▄ 

local function colorbox(name, c)
  local cbox = wibox.widget({
    {
      {
        forced_height = dpi(20),
        forced_width  = dpi(40),
        bg     = c,
        widget = wibox.container.background,
      },
      ui.textbox({
        text = name,
        align = "center",
      }),
      spacing = dpi(5),
      layout  = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
    -----
    color = c,
    mouseover_color = clrutils.darken(c, 0.2),
    update_color = function(self, _c)
      self.children[1].children[1].bg = _c
    end,
  })

  cbox:connect_signal("mouse::enter", function()
    cbox:update_color(cbox.mouseover_color)
  end)

  cbox:connect_signal("mouse::leave", function()
    cbox:update_color(cbox.color)
  end)

  cbox:connect_signal("button::press", function()
    awesome.emit_signal("colorpopup::toggle", c)
  end)

  return cbox
end

local function genlabel(label)
  return ui.textbox({
    text = label,
    font = beautiful.font_bold_s,
    align = "left",
  })
end

--- Generate palette display for a certain group.
-- @param label The name of the group
-- @param shades Colorboxes for the shades in the palettte.
local function gengroup(label, shades)
  local shades_wibox = wibox.widget({
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
  })
  shades_wibox.children = shades

  local label_wibox = label and genlabel(label) or nil

  return wibox.widget({
    label_wibox,
    shades_wibox,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })
end

-----

local title = ui.textbox({
  text = "Settings",
  font = beautiful.font_light_xl,
  align = "start",
})

-- Primary
local p_palette = {}
local primary = gengroup("Primary", {
  colorbox("100", beautiful.primary[100]),
  colorbox("200", beautiful.primary[200]),
  colorbox("300", beautiful.primary[300]),
  colorbox("400", beautiful.primary[400]),
  colorbox("500", beautiful.primary[500]),
  colorbox("600", beautiful.primary[600]),
  colorbox("700", beautiful.primary[700]),
})
local pbase = color.color { hex = beautiful.primary.base }

local neutral = gengroup("Neutral", {
  colorbox("100", beautiful.neutral[100]),
  colorbox("200", beautiful.neutral[200]),
  colorbox("300", beautiful.neutral[300]),
  colorbox("400", beautiful.neutral[400]),
  colorbox("500", beautiful.neutral[500]),
  colorbox("600", beautiful.neutral[600]),
  colorbox("700", beautiful.neutral[700]),
  colorbox("800", beautiful.neutral[800]),
  colorbox("900", beautiful.neutral[900]),
})

-- Red, green, yellow
local clabel = genlabel("Colors")

local _c_red = {
  colorbox("100", beautiful.red[100]),
  colorbox("200", beautiful.red[200]),
  colorbox("300", beautiful.red[300]),
  colorbox("400", beautiful.red[400]),
  colorbox("500", beautiful.red[500]),
}
local c_red = gengroup(nil, _c_red)

local _c_green = {
  colorbox("100", beautiful.green[100]),
  colorbox("200", beautiful.green[200]),
  colorbox("300", beautiful.green[300]),
  colorbox("400", beautiful.green[400]),
  colorbox("500", beautiful.green[500]),
}
local c_green = gengroup(nil, _c_green)

local _c_yellow = {
  colorbox("100", beautiful.yellow[100]),
  colorbox("200", beautiful.yellow[200]),
  colorbox("300", beautiful.yellow[300]),
  colorbox("400", beautiful.yellow[400]),
  colorbox("500", beautiful.yellow[500]),
}
local c_yellow = gengroup(nil, _c_yellow)

local shades = wibox.widget({
  clabel,
  c_red,
  c_green,
  c_yellow,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local _accents = {}
for i in ipairs(beautiful.accents) do
  _accents[#_accents+1] = colorbox(i, beautiful.accents[i])
end
local accents = gengroup("Accents", _accents)

local leftside = wibox.widget({
  primary,
  neutral,
  shades,
  accents,
  spacing = dpi(30),
  layout = wibox.layout.fixed.vertical,
})

-- █▀█ █ █▀▀ █░█ ▀█▀ █▀ █ █▀▄ █▀▀ 
-- █▀▄ █ █▄█ █▀█ ░█░ ▄█ █ █▄▀ ██▄ 

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

local rightside = wibox.widget({
  primary_preview,
  neutral_preview,
  shade_preview,
  accent_preview,
  spacing = dpi(20),
  layout  = wibox.layout.fixed.vertical,
})

return wibox.widget({
  leftside,
  rightside,
  spacing = dpi(20),
  layout = wibox.layout.fixed.horizontal,
})
