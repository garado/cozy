
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local color = require("modules.color")
local clrutils = require("utils.color")

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

local content = wibox.widget({
  {
    primary,
    neutral,
    shades,
    accents,
    spacing = dpi(30),
    layout = wibox.layout.fixed.vertical,
  },
  preview,
  spacing = dpi(50),
  layout = wibox.layout.fixed.horizontal,
})

-------------------------

local beautiful_name = ui.textbox({
  text = "Nord Dark",
  align = "left",
  font = beautiful.font_reg_l,
})

local container = wibox.widget({
  title,
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.09, 0.91)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
