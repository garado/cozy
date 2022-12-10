
-- █▀█ █▀█ █░█░█ █▀▀ █▀█    █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄    █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local elevated = require("modules.keynav.navitem").Elevated
local control = require("core.cozy.control")
local Area = require("modules.keynav.area")

local nav_power = Area:new({ name = "nav_power" })

local nav_power_opts = Area:new({
  name = "power_opts",
  group = "power_opts",
  is_row = true,
  circular = true,
})

local nav_power_confirm = Area:new({
  name = "power_confirm",
  group = "power_confirm",
  is_row = true,
  circular = true,
})

nav_power:append(nav_power_opts)

local state = "idle"
local func = nil

local yes = widgets.button.text.normal({
  text = "Yes",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.switcher_opt_btn_bg,
  animate_size = false,
  size = 12,
  on_release = function()
    if func ~= nil then
      func()
    end
    nav_power:remove_item(nav_power_confirm)
    control:emit_signal("power::confirm_toggle")
  end
})
nav_power_confirm:append(elevated:new(yes))

local no = widgets.button.text.normal({
  text = "No",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.switcher_opt_btn_bg,
  animate_size = false,
  size = 12,
  on_release = function()
    state = "idle"
    nav_power:remove_item(nav_power_confirm)
    control:emit_signal("power::confirm_toggle")
  end
})
nav_power_confirm:append(elevated:new(no))

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
  bg = beautiful.ctrl_powopt_bg,
  widget = wibox.container.background,
})

local function set_confirmation_text(text)
  text = text:gsub("^%l", string.upper) .. "?"
  local markup = helpers.ui.colorize_text(text, beautiful.fg)
  confirmation:get_children_by_id("dialogue")[1]:set_markup_silently(markup)
  state = "confirming"
end

local function create_power_btn(icon, confirm_text, cmd)
  local btn = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.ctrl_powopt_btn_fg,
    normal_bg = beautiful.ctrl_powopt_bg,
    animate_size = false,
    size = 13,
    on_release = function()
      if not nav_power:contains(nav_power_confirm) then
        nav_power:append(nav_power_confirm)
      end
      set_confirmation_text(confirm_text)
      control:emit_signal("power::confirm_on")
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
  bg = beautiful.ctrl_powopt_bg,
  widget = wibox.container.background,
})

return function()
  return options, confirmation, nav_power
end
