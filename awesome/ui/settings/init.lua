
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

local awful = require("awful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local keygrabber = require("awful.keygrabber")
local naughty = require("naughty")


local selected_theme = nil

local curr_theme_name = wibox.widget({
  widget = wibox.widget.textbox,
})

local current_theme = wibox.widget({
  wibox.widget ({
    markup = helpers.ui.colorize_text("Current theme: ", beautiful.fg),
    font = beautiful.font_name .. "Bold",
    widget = wibox.widget.textbox,
  }),
  curr_theme_name,
  spacing = dpi(3),
  layout = wibox.layout.fixed.horizontal,
})

local function get_current_theme()
  local user_vars = gfs.get_configuration_dir() .. "user_variables.lua"
  local cmd = "grep 'theme = .*' " .. user_vars
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local curr_theme = string.gsub(stdout, "[\n\r]", "")
    curr_theme = string.gsub(curr_theme, ".*theme = \"", "")
    curr_theme = string.gsub(curr_theme, "\".*", "")
    local markup = helpers.ui.colorize_text(curr_theme, beautiful.fg)
    curr_theme_name:set_markup_silently(markup)
  end)
end

get_current_theme()

local function set_current_theme(name)
  local user_vars = gfs.get_configuration_dir() .. "user_variables.lua"
  local replace_text = "theme = \"" .. name .. "\","
  local cmd = "sed -i 's/theme = .*/" .. replace_text .. "/g' " .. user_vars
  awful.spawn.with_shell(cmd)
end

local apply_theme_change = wibox.widget({
  widgets.button.text.normal({
    text = "Apply",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.settings_apply_btn_bg, 
    animate_size = false,
    size = 10,
    on_release = function()
      set_current_theme(selected_theme)
      awesome.restart()
    end 
  }),
  widget = wibox.container.place,
})
apply_theme_change.visible = false

local cancel_theme_change
cancel_theme_change = wibox.widget({
  widgets.button.text.normal({
    text = "Cancel",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.settings_cancel_btn_bg,
    animate_size = false,
    size = 10,
    on_release = function()
      local markup = helpers.ui.colorize_text("Current theme:" , beautiful.fg)
      current_theme.children[1]:set_markup_silently(markup)
      apply_theme_change.visible = false
      cancel_theme_change.visible = false
      get_current_theme()
    end 
  }),
  widget = wibox.container.place,
})
cancel_theme_change.visible = false

local function select_new_theme(name)
  local markup = helpers.ui.colorize_text("Selected:" , beautiful.fg)
  current_theme.children[1]:set_markup_silently(markup)

  local theme_markup = helpers.ui.colorize_text(name, beautiful.fg)
  curr_theme_name:set_markup_silently(theme_markup)

  apply_theme_change.visible = true
  cancel_theme_change.visible = true
end

local function create_theme_button(name)
  return widgets.button.text.normal({
    text = name,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.wibar_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      select_new_theme(name)
      selected_theme = name
    end 
  })
end

local theme_buttons = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local function create_theme_buttons()
  local themes_dir = gfs.get_configuration_dir() .. "theme/colorschemes/"
  local cmd = "ls " .. themes_dir
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    for theme in string.gmatch(stdout, "[^\n\r]+") do 
      theme = string.gsub(theme, ".lua", "")
      local theme_button = create_theme_button(theme)
      theme_buttons:add(theme_button)
    end
  end)
end

create_theme_buttons()

return function(s)
  local screen_height = dpi(s.geometry.height)
  local screen_width = dpi(s.geometry.width)

  -- assemble the control center
  local settings_contents = wibox.widget({
    {
      { -- body
        theme_buttons,
        margins = dpi(25),
        widget = wibox.container.margin,
      }, -- end body
      { -- lower tab
        {
          {
            current_theme,
            apply_theme_change,
            cancel_theme_change,
            forced_height = dpi(50),
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.place,
        },
        bg = beautiful.ctrl_lowerbar_bg,
        widget = wibox.container.background,
      }, -- end lower tab
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  })

  local settings_width = dpi(500)
  local settings = awful.popup ({
    type = "popup_menu",
    minimum_height = settings_height,
    maximum_height = settings_height,
    minimum_width = settings_width,
    maximum_width = settings_width,
    placement = awful.placement.centered,
    bg = beautiful.transparent,
    shape = gears.shape.rect,
    ontop = true,
    visible = false,
    widget = settings_contents,
  })


  -- keybind to toggle (default is Super_L + l)
  awesome.connect_signal("settings::toggle", function()
    settings.visible = not settings.visible
  end)

  return settings
end

