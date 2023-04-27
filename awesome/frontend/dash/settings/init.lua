
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local color = require("modules.color")
local clrutils = require("utils.color")
local theme = require("theme.colorschemes.nord.dark")

require(... .. ".popup")
local preview = require(... .. ".preview")()

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
    awesome.emit_signal("colorpopup::toggle", color)
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
  text = "Theme manager",
  font = beautiful.font_light_xl,
  align = "start",
})

-- Primary
local p_palette = {}
local primary = gengroup("Primary", {
  colorbox("100", theme.primary[100]),
  colorbox("200", theme.primary[200]),
  colorbox("300", theme.primary[300]),
  colorbox("400", theme.primary[400]),
  colorbox("500", theme.primary[500]),
})
local pbase = color.color { hex = theme.primary.base }

local neutral = gengroup("Neutral", {
  colorbox("100", theme.neutral[100]),
  colorbox("200", theme.neutral[200]),
  colorbox("300", theme.neutral[300]),
  colorbox("400", theme.neutral[400]),
  colorbox("500", theme.neutral[500]),
  colorbox("600", theme.neutral[600]),
  colorbox("700", theme.neutral[700]),
  colorbox("800", theme.neutral[800]),
  colorbox("900", theme.neutral[900]),
})

-- Red, green, yellow
local clabel = genlabel("Colors")

local _c_red = {
  colorbox("100", theme.red[100]),
  colorbox("200", theme.red[200]),
  colorbox("300", theme.red[300]),
  colorbox("400", theme.red[400]),
  colorbox("500", theme.red[500]),
}
local c_red = gengroup(nil, _c_red)

local _c_green = {
  colorbox("100", theme.green[100]),
  colorbox("200", theme.green[200]),
  colorbox("300", theme.green[300]),
  colorbox("400", theme.green[400]),
  colorbox("500", theme.green[500]),
}
local c_green = gengroup(nil, _c_green)

local _c_yellow = {
  colorbox("100", theme.yellow[100]),
  colorbox("200", theme.yellow[200]),
  colorbox("300", theme.yellow[300]),
  colorbox("400", theme.yellow[400]),
  colorbox("500", theme.yellow[500]),
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
for i in ipairs(theme.accents) do
  _accents[#_accents+1] = colorbox("100", theme.accents[i])
end
local accents = gengroup("Accents", _accents)

local ugh = wibox.widget({
  {
    primary,
    neutral,
    shades,
    accents,
    spacing = dpi(30),
    layout = wibox.layout.fixed.vertical,
  },
  preview,
  layout = wibox.layout.fixed.horizontal,
})

-------------------------

local theme_name = ui.textbox({
  text = "Nord Dark",
  align = "left",
  font = beautiful.font_reg_l,
})

local container = wibox.widget({
  title,
  {
    theme_name,
    ugh,
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.1, 0.9)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
