
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local config = require("cozyconf")
local dpi   = xresources.apply_dpi
local wibox = require("wibox")
local gears = require("gears")
local ui    = require("helpers.ui")
local dash  = require("core.cozy.dash")
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

local name = wibox.widget({
  markup  = ui.colorize(config.display_name or "Display Name", beautiful.primary_0),
  align   = "center",
  valign  = "center",
  font    = beautiful.font_reg_l,
  widget  = wibox.widget.textbox,
})

local title = wibox.widget({
  markup  = ui.colorize("Uses Arch, btw", beautiful.fg_0),
  font    = beautiful.font_reg_s,
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textbox,
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
      layout = wibox.layout.fixed.vertical,
    },
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

return ui.box(profile, dpi(400), dpi(200), beautiful.dash_bg)
