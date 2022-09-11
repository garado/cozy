
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
local nav = require("ui.nav.navclass")
local tree = require("ui.nav.tree")
local navigate = require("ui.theme_switcher.navigate")

local selected_theme = ""
local selected_style = ""

-- some necessary forward declarations
local apply_new_theme, get_current_theme, reset_theme_switcher
local styles

-- for navigable elements
local Navtree = tree:new(3)

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
-- Sets theme switcher back to default settings
function reset_theme_switcher()
  local markup = helpers.ui.colorize_text("Current: " , beautiful.fg)
  theme_sel_textbox:set_markup_silently(markup)
  apply_button.visible = false
  cancel_button.visible = false
  styles.visible = false
  Navtree:reset_level(2)
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
  local cfg = gfs.get_configuration_dir()
  local path = cfg .. "theme/colorschemes/" .. theme .. "/" .. style .. ".lua"
  local theme_exists = gfs.file_readable(path)
  if not theme_exists or style == "" or style == nil then
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
  awesome.emit_signal("nav::update_navtree", Navtree)
end

local function create_style_button(style)
  local style_button = widgets.button.text.normal({
    text = style,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_options_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      select_new_style(style)
      selected_style = style
      Navtree:append(3, "apply")
      Navtree:append(3, "cancel")
      nav.Elevated:new(apply_button.children[1],  "apply")
      nav.Elevated:new(cancel_button.children[1], "cancel")
      apply_button.visible  = true
      cancel_button.visible = true
    end
  })
  local signal_name = selected_theme .. "_" .. style
  nav.Elevated:new(style_button, signal_name)
  Navtree:append(2, signal_name)

  return wibox.widget ({
    style_button,
    widget = wibox.container.place,
  })
end

local function create_style_buttons(theme)
  -- remove old style buttons
  style_buttons:reset()
  Navtree:reset_level(2)

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
    awesome.emit_signal("nav::update_navtree", Navtree)
  end)
end

local function select_new_theme(theme)
  local markup = helpers.ui.colorize_text("Selected: " , beautiful.fg)
  theme_sel_textbox:set_markup_silently(markup)

  local theme_markup = helpers.ui.colorize_text(theme, beautiful.fg)
  theme_name_textbox:set_markup_silently(theme_markup)

  styles.visible = true
  selected_style = ""

  create_style_buttons(theme)
end

local function create_theme_button(name)
  local theme_button = widgets.button.text.normal({
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
      return 24
    end
  })
  nav.Elevated:new(theme_button, name)
  Navtree:append(1, name)
  return theme_button
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
apply_button.visible = false
cancel_button.visible = false
styles.visible = false

return function()
  -- assemble the theme_switcher menu
  local theme_switcher_contents = wibox.widget({
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

  local theme_switcher_width = dpi(500)
  local theme_switcher = awful.popup ({
    type = "popup_menu",
    minimum_width = theme_switcher_width,
    maximum_width = theme_switcher_width,
    placement = awful.placement.centered,
    bg = beautiful.transparent,
    shape = gears.shape.rect,
    ontop = true,
    visible = false,
    widget = theme_switcher_contents,
  })

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  awesome.connect_signal("theme_switcher::toggle", function()
    theme_switcher.visible = not theme_switcher.visible
    if not theme_switcher.visible then
      reset_theme_switcher()
    else
      require("ui.shared").close_other_popups("theme_switcher")
      navigate(Navtree)
    end
  end)

  awesome.connect_signal("theme_switcher::open", function()
    theme_switcher.visible = true
  end)

  awesome.connect_signal("theme_switcher::close", function()
    theme_switcher.visible = false
    reset_theme_switcher()
  end)

  awesome.connect_signal("fuckyou", function()
    Navtree:print_contents()
  end)

  return theme_switcher
end
