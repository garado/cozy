
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui    = require("helpers.ui")

local keynav = require("modules.keynav")
local tscore = require("core.cozy.themeswitcher")

local widgets = require("ui.widgets")
local vpad = require("helpers.ui").vertical_pad
local colorize = require("helpers.ui").colorize_text

local Elevated = require("modules.keynav.navitem").Elevated

-------------------

local nav_themes  = keynav.area({
  name = "nav_themes"
})

local nav_styles = keynav.area({
  name   = "nav_styles",
  is_row = true
})

local nav_actions = keynav.area({
  name   = "nav_actions",
  is_row = true
})

local navigator, nav_root = keynav.navigator({
  root_children = { nav_themes }
})

-- Module-level vars
local theme_sel_textbox, theme_name_textbox, theme_style_textbox, current_selections
local styles, action_buttons, style_buttons

local create_style_buttons

------------------------------------------

--- Update UI to reflect newly selected theme.
-- @param theme The name of the theme selected.
local function select_new_theme(theme)
  local markup = ui.colorize("Selected: " , beautiful.fg_0)
  theme_sel_textbox:set_markup_silently(markup)

  local theme_markup = ui.colorize(theme, beautiful.fg_0)
  theme_name_textbox:set_markup_silently(theme_markup)

  styles.visible = true
  create_style_buttons(theme)
end

--- Update UI to reflect newly selected style
local function select_new_style(style)
end

--- Reset theme switcher UI back to default state.
local function reset_theme_switcher()
  local markup = ui.colorize("Current: " , beautiful.fg_0)
  theme_sel_textbox:set_markup_silently(markup)
  action_buttons.visible = false
  styles.visible = false
  nav_styles:remove_all_items()
  nav_root:remove_item(nav_actions)
  nav_root:remove_item(nav_styles)
end

------------------------------------------

-- █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ █▀ 
-- █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ ▄█ 

local themes_header = wibox.widget({
  markup = colorize("Themes", beautiful.primary_0),
  font   = beautiful.font_med_s,
  align  = "center",
  widget = wibox.widget.textbox,
})

local styles_header = wibox.widget({
  markup = colorize("Styles", beautiful.primary_0),
  font   = beautiful.font_med_s,
  align  = "center",
  widget = wibox.widget.textbox,
})

-- █▄▄ █░█ ▀█▀ ▀█▀ █▀█ █▄░█ █▀ 
-- █▄█ █▄█ ░█░ ░█░ █▄█ █░▀█ ▄█ 

--- Create a single theme button
local function create_theme_button(themename)
  local btn, nav_btn = ui.simple_button({
    text   = themename,
    font   = beautiful.font_reg_s,
    bg     = beautiful.bg_3,
    bg_on  = beautiful.bg_5,
    height = dpi(40),
    width  = dpi(200),
    release = function()
      nav_styles:remove_all_items()
      tscore.selected_theme = themename
      tscore.selected_style = ""
      theme_style_textbox:set_markup_silently("", beautiful.fg_0)
      select_new_theme(themename)
    end,
  })

  nav_themes:append(nav_btn)

  return wibox.widget({
    {
      btn,
      forced_width = dpi(200),
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  })
end

local function create_style_button(style)
  local btn, nav_btn = ui.simple_button({
    text   = style,
    font   = beautiful.font_reg_s,
    bg     = beautiful.bg_3,
    bg_on  = beautiful.bg_5,
    height = dpi(40),
    width  = dpi(100),
    release = function()
      tscore.selected_style = style
      action_buttons.visible = true
      if not nav_root:contains(nav_actions) then
        nav_root:append(nav_actions)
      end
      -- select_new_style(style)
    end,
  })

  return btn, nav_btn
end

function create_style_buttons(theme)
  style_buttons:reset()
  local _styles = tscore.themes[theme]
  for i = 1, #_styles do
    local btn, nav_btn = create_style_button(_styles[i])
    style_buttons:add(btn)
    nav_styles:add(nav_btn)
  end

  if not nav_root:contains(nav_styles) then
    nav_root:append(nav_styles)
  end
end

local apply_btn, nav_apply = ui.simple_button({
  text    = "Apply",
  bg      = beautiful.bg_1,
  bg_off  = beautiful.bg_3,
  release = function()
    tscore:apply_selected_theme()
  end
})

local cancel_btn, nav_cancel = ui.simple_button({
  text    = "Cancel",
  bg      = beautiful.bg_1,
  bg_off  = beautiful.bg_3,
  release = function()
    reset_theme_switcher()
  end
})

nav_actions:add(nav_apply)
nav_actions:add(nav_cancel)

-- █▄▄ █░█ ▀█▀ ▀█▀ █▀█ █▄░█    █▀▀ █▀█ █▄░█ ▀█▀ ▄▀█ █ █▄░█ █▀▀ █▀█ █▀
-- █▄█ █▄█ ░█░ ░█░ █▄█ █░▀█    █▄▄ █▄█ █░▀█ ░█░ █▀█ █ █░▀█ ██▄ █▀▄ ▄█

local theme_buttons = wibox.widget({
  spacing = dpi(10),
  forced_width = dpi(200),
  layout = wibox.layout.fixed.vertical,
})

style_buttons = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

action_buttons = wibox.widget({
  {
    apply_btn,
    cancel_btn,
    forced_height = dpi(50),
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  },
  visible = false,
  widget = wibox.container.place,
})

------------------------------------------

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- This is where we put all the wiboxes together and assemble the whole widget

styles = wibox.widget({
  {
    vpad(dpi(10)),
    styles_header,
    style_buttons,
    vpad(dpi(10)),
    spacing = dpi(10),
    forced_height = dpi(100),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

local themes = wibox.widget({
  {
    themes_header,
    theme_buttons,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(25),
  widget = wibox.container.margin,
})

-- Shows you the current theme and style if you haven't selected anything
-- Or the selected theme and style if you have
current_selections = wibox.widget({
  {
    -- "Current:" or "Selected:"
    markup = colorize("Current: ", beautiful.fg_0),
    font   = beautiful.font_med_s,
    widget = wibox.widget.textbox,
  },
  {
    markup = colorize(tscore.applied_theme, beautiful.fg_0),
    font   = beautiful.font_reg_s,
    id     = "theme_name",
    widget = wibox.widget.textbox,
  },
  {
    markup = colorize(" (" .. tscore.applied_style .. ")", beautiful.fg_0),
    font   = beautiful.font_reg_s,
    id     = "theme_style",
    widget = wibox.widget.textbox,
  },
  forced_height = dpi(50),
  layout = wibox.layout.fixed.horizontal,
})

theme_sel_textbox   = current_selections.children[1]
theme_name_textbox  = current_selections.children[2]
theme_style_textbox = current_selections.children[3]

local selections_and_actions = wibox.widget({
  {
    current_selections,
    action_buttons,
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

local theme_switcher_width = dpi(350)
local theme_switcher = awful.popup ({
  type = "popup_menu",
  minimum_width = theme_switcher_width,
  maximum_width = theme_switcher_width,
  placement = awful.placement.centered,
  bg = beautiful.transparent,
  shape = gears.shape.rect,
  ontop = true,
  visible = false,
  widget = wibox.widget({
    {
      themes,
      styles,
      {
        selections_and_actions,
        bg     = beautiful.bg_0,
        widget = wibox.container.background,
      },
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.switcher_bg,
  })
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- When tscore is finished grabbing information,
tscore:connect_signal("update::themes", function()
  themes = tscore.themes
  reset_theme_switcher()
  nav_themes:remove_all_items()
  theme_buttons:reset()
  for theme in pairs(themes) do
    local tbutton = create_theme_button(theme)
    theme_buttons:add(tbutton)
  end
end)

tscore:connect_signal("setstate::open", function()
  theme_switcher.visible = true
  navigator:start()
end)

tscore:connect_signal("setstate::close", function()
  theme_switcher.visible = false
  reset_theme_switcher()
  navigator:stop()
end)

return function()
  return theme_switcher
end
