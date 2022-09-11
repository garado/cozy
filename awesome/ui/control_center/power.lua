
-- █▀█ █▀█ █░█░█ █▀▀ █▀█    █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄    █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local nav = require("ui.nav.navclass")

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

return function(navtree)
  local function create_power_btn(icon, confirm_text, cmd)
    local btn = widgets.button.text.normal({
      text = icon,
      text_normal_bg = beautiful.ctrl_power_options_btn_fg,
      normal_bg = beautiful.ctrl_power_options_bg,
      animate_size = false,
      size = 13,
      on_release = function()
        navtree:append(4, yes)
        navtree:append(4, no)
        nav.Elevated.new(yes, "yes")
        nav.Elevated.new(no, "no")
        awesome.emit_signal("nav::update_navtree", navtree)
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

    local signal_name = string.gsub(confirm_text, "?", "")
    navtree:append(3, signal_name)
    nav.Elevated:new(btn, signal_name)

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

  options = wibox.widget({
    {
      {
        create_power_btn("", "sleep", "systemctl suspend"),
        create_power_btn("", "lock", "dm-tool lock"),
        create_power_btn("", "log out", "pkill awesome"),
        create_power_btn("", "restart", "systemctl reboot"),
        create_power_btn("", "shut down", "systemctl poweroff"),
        layout = wibox.layout.flex.horizontal,
      },
      widget = wibox.container.place,
    },
    forced_width = dpi(220),
    bg = beautiful.ctrl_power_options_bg,
    widget = wibox.container.background,
  })

  return options, confirmation
end
