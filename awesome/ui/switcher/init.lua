
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
local naughty = require("naughty")

local selected_theme = ""
local selected_style = ""

-- some necessary forward declarations
local apply_new_theme, get_current_theme, reset_theme_switcher
local styles

-- █░█░█ █ █▄▄ █▀█ ▀▄▀ █▀▀ █▀ 
-- ▀▄▀▄▀ █ █▄█ █▄█ █░█ ██▄ ▄█ 

local curr_theme_sel = wibox.widget({
  wibox.widget ({
    -- "Current:" or "Selected:"
    markup = helpers.ui.colorize_text("Current: ", beautiful.fg),
    font = beautiful.font_name .. "Bold",
    widget = wibox.widget.textbox,
  }),
  wibox.widget ({
    id = "theme_name",
    widget = wibox.widget.textbox,
  }),
  wibox.widget ({
    id = "theme_style",
    widget = wibox.widget.textbox,
  }),
  spacing = dpi(2),
  layout = wibox.layout.fixed.horizontal,
})

local theme_sel_textbox   = curr_theme_sel.children[1]
local theme_name_textbox  = curr_theme_sel.children[2]
local theme_style_textbox = curr_theme_sel.children[3]

local apply_button = wibox.widget({
  widgets.button.text.normal({
    text = "Apply",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_apply_btn_bg,
    animate_size = false,
    size = 10,
    on_release = function()
      apply_new_theme(selected_theme, selected_style)
    end
  }),
  widget = wibox.container.place,
})
apply_button.visible = false

local cancel_button
cancel_button = wibox.widget({
  widgets.button.text.normal({
    text = "Cancel",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_cancel_btn_bg,
    animate_size = false,
    size = 10,
    on_release = function()
      reset_theme_switcher()
    end,
  }),
  widget = wibox.container.place,
})

local style_buttons = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

local theme_buttons = wibox.widget({
  spacing = dpi(10),
  forced_width = dpi(200),
  layout = wibox.layout.fixed.vertical,
})

local theme_header = wibox.widget({
  markup = helpers.ui.colorize_text("Themes", beautiful.switcher_header_fg),
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

local style_header = wibox.widget({
  markup = helpers.ui.colorize_text("Styles", beautiful.switcher_header_fg),
  align = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

styles = wibox.widget ({
  helpers.ui.vertical_pad(dpi(10)),
  style_header,
  style_buttons,
  helpers.ui.vertical_pad(dpi(10)),
  spacing = dpi(10),
  forced_height = dpi(100),
  layout = wibox.layout.fixed.vertical,
})


-- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

function reset_theme_switcher()
  local markup = helpers.ui.colorize_text("Current:" , beautiful.fg)
  theme_sel_textbox:set_markup_silently(markup)
  apply_button.visible = false
  cancel_button.visible = false
  styles.visible = false
  get_current_theme()
end

-- Returns currently selected theme and style in user_variables.lua
function get_current_theme()
  local user_vars = gfs.get_configuration_dir() .. "user_variables.lua"
  local cmd = "egrep 'theme_name.*|theme_style.*' " .. user_vars
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local fields = { }
    for field in stdout:gmatch('"(.-)"') do
      table.insert(fields, field)
    end
    local curr_theme = fields[1]
    local curr_style = fields[2]
    local style_text = " (" .. curr_style .. ")"
    local style_markup = helpers.ui.colorize_text(style_text, beautiful.fg)
    local theme_markup = helpers.ui.colorize_text(curr_theme, beautiful.fg)
    theme_name_textbox:set_markup_silently(theme_markup)
    theme_style_textbox:set_markup_silently(style_markup)
  end)
end

-- Edits user_vars with selected theme and style
function apply_new_theme(theme, style)
  if style == "" or style == nil then
    naughty.notification {
      app_name = "System notification",
      title = "Theme switcher",
      message = "Select a style to proceed!",
    }
    return
  end
  local user_vars = gfs.get_configuration_dir() .. "user_variables.lua"
  local replace_theme = "sed -i 's/theme_name.*/theme_name = \"" .. theme .. "\",/' "
  local replace_style = "sed -i 's/theme_style.*/theme_style = \"" .. style .. "\",/' "
  awful.spawn.with_shell(replace_theme .. user_vars)
  awful.spawn.with_shell(replace_style .. user_vars)
  awesome.restart()
end

local function select_new_style(style)
  local text = " (" .. style .. ")"
  local style_markup = helpers.ui.colorize_text(text, beautiful.fg)
  theme_style_textbox:set_markup_silently(style_markup)
end

local function create_style_button(style)
  local button = widgets.button.text.normal({
    text = style,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_options_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      select_new_style(style)
      selected_style = style
    end
  })

  return wibox.widget ({
    button,
    widget = wibox.container.place,
  })
end

local function create_style_buttons(theme)
  -- remove old style buttons
  style_buttons:reset()

  local cfg = gfs.get_configuration_dir()
  local themes_dir = cfg .. "theme/colorschemes/" .. theme .. "/"
  local cmd = "ls " .. themes_dir
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    for style in string.gmatch(stdout, "[^\n\r]+") do
      if style ~= "init.lua" then
        style = string.gsub(style, ".lua", "")
        local style_button = create_style_button(style)
        style_buttons:add(style_button)
      end
    end
  end)
end

local function select_new_theme(theme)
  local markup = helpers.ui.colorize_text("Selected:" , beautiful.fg)
  theme_sel_textbox:set_markup_silently(markup)

  local theme_markup = helpers.ui.colorize_text(theme, beautiful.fg)
  theme_name_textbox:set_markup_silently(theme_markup)

  apply_button.visible = true
  cancel_button.visible = true
  styles.visible = true

  create_style_buttons(theme)
end

local function create_theme_button(name)
  return widgets.button.text.normal({
    text = name,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_options_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      select_new_theme(name)
      selected_theme = name
      selected_style = ""
      theme_style_textbox:set_markup_silently("", beautiful.fg)
    end
  })
end

local function create_theme_buttons()
  local themes_dir = gfs.get_configuration_dir() .. "theme/colorschemes/"
  local cmd = "ls " .. themes_dir
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    for theme in string.gmatch(stdout, "[^\n\r]+") do
      if theme ~= "init.lua" then
        theme = string.gsub(theme, ".lua", "")
        local theme_button = create_theme_button(theme)
        theme_buttons:add(theme_button)
      end
    end
  end)
end

-- execute
get_current_theme()
create_theme_buttons()
cancel_button.visible = false
styles.visible = false

return function()
  -- assemble the settings menu
  local settings_contents = wibox.widget({
    {
      {
        {
          theme_header,
          theme_buttons,
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical,
        },
        margins = dpi(25),
        widget = wibox.container.margin,
      },
      {
        styles,
        widget = wibox.container.place,
      },
      { -- theme name
        {
          {
            curr_theme_sel,
            apply_button,
            cancel_button,
            forced_height = dpi(50),
            spacing = dpi(10),
            layout = wibox.layout.fixed.horizontal,
          },
          widget = wibox.container.place,
        },
        bg = beautiful.switcher_lowerbar_bg,
        widget = wibox.container.background,
      },
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  })

  local settings_width = dpi(500)
  local settings = awful.popup ({
    type = "popup_menu",
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
    if not settings.visible then
      reset_theme_switcher()
    end
  end)

  return settings
end

