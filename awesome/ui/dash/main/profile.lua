
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")
local helpers = require("helpers")
local config = require("config")

local math = math

local function create_profile()
  local image = wibox.widget({
    {
      image = beautiful.pfp,
      resize = true,
      clip_shape = gears.shape.circle,
      halign = "center",
      valign = "center",
      widget = wibox.widget.imagebox,
    },
    border_width = dpi(0),
    shape = gears.shape.circle,
    bg = beautiful.prof_pfp_bg,
    forced_width = dpi(100),
    forced_height = dpi(100),
    widget = wibox.container.background,
  })

  local display_name = config.display_name
  local name = wibox.widget({
    widget = wibox.widget.textbox,
    markup = helpers.ui.colorize_text(display_name, beautiful.prof_name_fg),
    font = beautiful.font_name .. "18",
    align = "center",
    valign = "center",
  })
  
  local host = wibox.widget({
    widget = wibox.widget.textbox,
    markup = helpers.ui.colorize_text("@andromeda", beautiful.prof_title_fg),
    font = beautiful.font_name .. "18",
    align = "center",
    valign = "center",
  })
  
  local title = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "11",
    markup = helpers.ui.colorize_text("Uses Arch, btw", beautiful.fg),
    align = "center",
    valign = "center",
  })
 
  -- new title every time you open dash
  awesome.connect_signal("dash::closed", function()
    local titles_list = config.titles
    local random_title = titles_list[math.random(#titles_list)]
    title:set_markup(helpers.ui.colorize_text(random_title, beautiful.fg))
  end)
  
  local profile = wibox.widget({
    {
      image,
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

  return profile 
end

return helpers.ui.create_boxed_widget(create_profile(), dpi(400), dpi(180), beautiful.dash_bg)

