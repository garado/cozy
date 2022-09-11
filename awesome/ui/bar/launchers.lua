
-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ █▀ 
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ ▄█ 

local beautiful = require("beautiful")
local widgets = require("ui.widgets")
local helpers = require("helpers")
local wibox = require("wibox")

local function markup(icon, color)
  return helpers.ui.colorize_text(icon, color)
end

local function create_launcher(icon, signal, color)
  local button = wibox.widget({
    markup = markup(icon, color),
    widget = wibox.widget.textbox,
    font = beautiful.font .. "12",
    align = "center",
    valign = "center",
  })
  button:connect_signal("button::press", function()
    awesome.emit_signal(signal)
  end)
  button:connect_signal("mouse::enter", function()
    button:set_markup_silently(markup(icon, beautiful.wibar_launcher_hover))
  end)
  button:connect_signal("mouse::leave", function()
    button:set_markup_silently(markup(icon, color))
  end)
  return button
end

return {
  create_launcher("異", "dash::toggle", beautiful.wibar_launcher_dash),
  create_launcher("שּׂ", "control_center::toggle", beautiful.wibar_launcher_ctrl),
  create_launcher("襁", "theme_switcher::toggle", beautiful.wibar_launcher_settings),
}
