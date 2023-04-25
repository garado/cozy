
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local beautiful  = require("beautiful")
local config = require("cozyconf")
local wibox = require("wibox")
local gears = require("gears")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local dash  = require("backend.state.dash")
local math  = math

local pfp = wibox.widget({
  {
    image   = beautiful.pfp,
    resize  = true,
    halign  = "center",
    valign  = "center",
    clip_shape = gears.shape.circle,
    widget  = wibox.widget.imagebox,
  },
  bg    = beautiful.prof_pfp_bg,
  shape = gears.shape.circle,
  border_width  = dpi(0),
  forced_width  = dpi(100),
  forced_height = dpi(100),
  widget = wibox.container.background,
})

local name = ui.textbox({
  text  = config.display_name or "Display Name",
  color = beautiful.primary_0,
  font  = beautiful.font_reg_l,
})

local title = ui.textbox({
  text = "Uses Arch, btw",
})

-- New title every time you open dash
dash:connect_signal("setstate::close", function()
  local titles_list  = config.titles or { "Linux enthusiast" }
  local random_title = titles_list[math.random(#titles_list)]
  title:set_markup(ui.colorize(random_title, beautiful.fg_0))
end)

local profile = wibox.widget({
  {
    pfp,
    {
      name,
      title,
      spacing = dpi(2),
      layout  = wibox.layout.fixed.vertical,
    },
    spacing = dpi(5),
    layout  = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

return ui.dashbox(profile, dpi(400), dpi(200), beautiful.dash_bg)
