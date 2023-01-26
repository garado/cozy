
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local config = require("cozyconf")
local dash = require("core.cozy.dash")
local math = math

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
  align   = "center",
  valign  = "center",
  font    = beautiful.base_large_font,
  markup  = colorize(config.display_name or "Display Name", beautiful.prof_name_fg),
  widget  = wibox.widget.textbox,
})

local title = wibox.widget({
  font    = beautiful.base_small_font,
  markup  = colorize("Uses Arch, btw", beautiful.fg),
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textbox,
})

-- New title every time you open dash
-- BUG: this signal isn't being emitted properly...
dash:connect_signal("setstate::close", function()
  local titles_list = config.titles or { "Linux enthusiast" }
  local random_title = titles_list[math.random(#titles_list)]
  title:set_markup(colorize(random_title, beautiful.fg))
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

return box(profile, dpi(400), dpi(180), beautiful.dash_bg)
