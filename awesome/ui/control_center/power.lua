
-- █▀█ █▀█ █░█░█ █▀▀ █▀█    █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄    █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local elevated = require("ui.nav.navclass").Elevated
local Box = require("ui.nav.box")

local nav_power_opts = Box:new({ name = "power_opts" })
local nav_power_confirm = Box:new({ name = "power_confirm" })

local state = "idle"
local func = nil

local yes = widgets.button.text.normal({
  text = "Yes",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.switcher_options_bg,
  animate_size = false,
  size = 12,
  on_release = function()
    if func ~= nil then
      func()
    end
    nav_power_confirm:clear_items()
    awesome.emit_signal("ctrl::power_confirm_toggle")
  end
})

local no = widgets.button.text.normal({
  text = "No",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.switcher_options_bg,
  animate_size = false,
  size = 12,
  on_release = function()
    state = "idle"
    nav_power_confirm:clear_items()
    awesome.emit_signal("ctrl::power_confirm_toggle")
  end
})

local confirmation = wibox.widget({
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
        no,
        spacing = dpi(20),
        layout = wibox.layout.fixed.horizontal,
      },
      spacing = dpi(15),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_height = dpi(60),
  bg = beautiful.ctrl_power_options_bg,
  widget = wibox.container.background,
})

local function set_confirmation_text(text)
  local text = text:gsub("^%l", string.upper) .. "?"
  local markup = helpers.ui.colorize_text(text, beautiful.fg)
  confirmation:get_children_by_id("dialogue")[1]:set_markup_silently(markup)
  state = "confirming"
end

local function create_power_btn(icon, confirm_text, cmd)
  local btn = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.ctrl_power_options_btn_fg,
    normal_bg = beautiful.ctrl_power_options_bg,
    animate_size = false,
    size = 13,
    on_release = function()
      nav_power_confirm:append(elevated:new(yes))
      nav_power_confirm:append(elevated:new(no))
      set_confirmation_text(confirm_text)
      awesome.emit_signal("ctrl::power_confirm_on")
      func = function()
        if state == "confirming" then
          state = "idle"
          awful.spawn(cmd)
        end
      end
    end
  })

  nav_power_opts:append(elevated:new(btn))

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

local options = wibox.widget({
  {
    {
      create_power_btn("", "sleep",     "systemctl suspend"),
      create_power_btn("", "lock",      "dm-tool lock"),
      create_power_btn("", "log out",   "pkill awesome"),
      create_power_btn("", "restart",   "systemctl reboot"),
      create_power_btn("", "shut down", "systemctl poweroff"),
      layout = wibox.layout.flex.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_width = dpi(220),
  bg = beautiful.ctrl_power_options_bg,
  widget = wibox.container.background,
})

return {
  power_opts = options,
  power_confirm = confirmation,
  nav_power_opts = nav_power_opts,
  nav_power_confirm = nav_power_confirm,
}
