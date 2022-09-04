
-- █▀█ █▀█ █░█░█ █▀▀ █▀█    █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄    █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local widgets = require("ui.widgets")
local animation = require("modules.animation")

-- forward decl(?) widgets
local confirmation, options, stack, func
local state = idle

local function confirm(text)
  local markup = helpers.ui.colorize_text(text, beautiful.fg)
  confirmation:get_children_by_id("dialogue")[1]:set_markup_silently(markup)
  stack:swap_widgets(confirmation, options)
  state = "confirming"
end

local function create_power_option_button(icon, confirm_text, cmd)
  local btn = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.ctrl_power_options_btn_fg,
    normal_bg = beautiful.ctrl_power_options_bg,
    animate_size = false,
    size = 13,
    on_release = function()
      if func ~= nil then
        awesome.disconnect_signal("ctrl::power_confirmed", func)
      end
      confirm(confirm_text)
      func = function()
        if state == "confirming" then
          state = "idle"
          stack:swap_widgets(confirmation, options)
          awful.spawn(cmd)
        end
      end
      awesome.connect_signal("ctrl::power_confirmed", func)
    end
  })

  return wibox.widget({
    {
      btn,
      forced_width = dpi(50),
      forced_height = dpi(50),
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  })
end

local yes = wibox.widget({
  markup = helpers.ui.colorize_text("Yes", beautiful.fg),
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})
yes:connect_signal("button::release", function()
  awesome.emit_signal("ctrl::power_confirmed")
end)
yes:connect_signal("mouse::enter", function()
  local markup = helpers.ui.colorize_text("Yes", beautiful.main_accent)
  yes:set_markup_silently(markup)
  yes.font = beautiful.font_name .. "Bold"
end)
yes:connect_signal("mouse::leave", function()
  local markup = helpers.ui.colorize_text("Yes", beautiful.fg)
  yes:set_markup_silently(markup)
  yes.font = beautiful.font_name
end)


local no = wibox.widget({
  markup = helpers.ui.colorize_text("No", beautiful.fg),
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})
no:connect_signal("button::release", function()
  state = "idle"
  stack:swap_widgets(confirmation, options)
end)
no:connect_signal("mouse::enter", function()
  local markup = helpers.ui.colorize_text("No", beautiful.main_accent)
  no:set_markup_silently(markup)
  no.font = beautiful.font_name .. "Bold"
end)
no:connect_signal("mouse::leave", function()
  local markup = helpers.ui.colorize_text("No", beautiful.fg)
  no:set_markup_silently(markup)
  no.font = beautiful.font_name
end)

confirmation = wibox.widget({
  {
    {
      {
        id = "dialogue",
        markup = helpers.ui.colorize_text("Shut down?", beautiful.fg),
        font = beautiful.font_name .. "Bold",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      {
        yes,
        {
          markup = helpers.ui.colorize_text("/", beautiful.fg),
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox,
        },
        no,
        spacing = dpi(5),
        layout = wibox.layout.fixed.horizontal,
      },
      spacing = dpi(15),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_width = dpi(220),
  bg = beautiful.ctrl_power_options_bg,
  widget = wibox.container.background,
})

options = wibox.widget({
  {
    {
      create_power_option_button("", "Sleep?", "systemctl suspend"),
      create_power_option_button("", "Lock?", "dm-tool lock"),
      create_power_option_button("", "Log out?", "pkill awesome"),
      create_power_option_button("", "Restart?", "systemctl reboot"),
      create_power_option_button("", "Shut down?", "systemctl poweroff"),
      layout = wibox.layout.flex.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_width = dpi(220),
  bg = beautiful.ctrl_power_options_bg,
  widget = wibox.container.background,
})

stack = wibox.widget({
  options,
  confirmation,
  top_only = true,
  layout = wibox.layout.stack,
})

return stack
