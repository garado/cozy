
-- █▄▄ ▄▀█ █▀█ ▀   █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█
-- █▄█ █▀█ █▀▄ ▄   █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful").xresources.apply_dpi
local helpers = require("helpers")
local gears = require("gears")
local widgets = require("ui.widgets")

local app_launcher

local function create_launcher_entry(icon, program)
  local entry = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.wibar_fg,
    normal_bg = beautiful.wibar_bg,
    animate_size = false,
    size = 20,
    on_release = function()
      awful.spawn(program)
      app_launcher.visible = not app_launcher.visible
    end,
  })

  return wibox.widget({
    entry,
    widget = wibox.container.place,
  })
end

app_launcher = awful.popup({
  widget = {
    {
      helpers.ui.vertical_pad(dpi(5)),
      create_launcher_entry("", "xournalpp"),
      create_launcher_entry("", "foliate"),
      create_launcher_entry("", "alacritty"),
      create_launcher_entry("", "thunar"),
      create_launcher_entry("", "firefox"),
      helpers.ui.vertical_pad(dpi(5)),
      spacing = dpi(5),
      forced_width = dpi(60),
      layout = wibox.layout.fixed.vertical,
    },
    bg = beautiful.wibar_bg,
    widget = wibox.container.background,
  },
  x = dpi(50),
  y = dpi(10),
  shape = gears.shape.rounded_rect,
  visible = false,
  ontop = true,
})

local button = wibox.widget({
  markup = helpers.ui.colorize_text("", beautiful.wibar_launch_app),
  widget = wibox.widget.textbox,
  font = beautiful.font_name .. "12",
  align = "center",
  valign = "center",
})

button:connect_signal("button::press", function()
  app_launcher.visible = not app_launcher.visible
  if app_launcher.visible then
    require("ui.shared").close_other_popups("app_launcher")
  end
end)

button:connect_signal("mouse::enter", function()
  local markup = helpers.ui.colorize_text("", beautiful.wibar_launch_hover)
  button:set_markup_silently(markup)
end)

button:connect_signal("mouse::leave", function()
  local markup = helpers.ui.colorize_text("", beautiful.wibar_launch_app)
  button:set_markup_silently(markup)
end)

awesome.connect_signal("app_launcher::close", function()
  app_launcher.visible = false
end)

return button
