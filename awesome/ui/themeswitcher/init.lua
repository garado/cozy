
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- This file is super messy. Good luck reading it lol.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")
local tscore = require("core.cozy.themeswitcher")
local vpad = require("helpers.ui").vertical_pad
local colorize = require("helpers.ui").colorize_text

local keynav = require("modules.keynav")
local Area = keynav.area
local Navigator = keynav.navigator
local Elevated = keynav.navitem.Elevated

------------------------------------------

-- Setup for keyboard navigation
local navigator, nav_root = Navigator:new()
local nav_themes  = Area:new({ name = "nav_themes"  })
local nav_styles  = Area:new({
  name = "nav_styles",
  is_row = true
})
local nav_actions = Area:new({
  name = "nav_actions",
  is_row = true
})
nav_root:append(nav_themes)

-- Module-level vars
local theme_sel_textbox, theme_name_textbox, theme_style_textbox, current_selections
local styles, action_buttons, style_buttons

local create_style_buttons

------------------------------------------

-- █░█ █    █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▄█ █    █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

--- Update UI to reflect newly selected theme.
-- @param theme The name of the theme selected.
local function select_new_theme(theme)
  local markup = colorize("Selected: " , beautiful.fg)
  theme_sel_textbox:set_markup_silently(markup)

  local theme_markup = colorize(theme, beautiful.fg)
  theme_name_textbox:set_markup_silently(theme_markup)

  styles.visible = true
  create_style_buttons(theme)
end

--- Reset theme switcher UI back to default state.
local function reset_theme_switcher()
  local markup = colorize("Current: " , beautiful.fg)
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

local function create_themeswitch_header(text)
  return wibox.widget({
    markup = colorize(text, beautiful.switcher_header_fg),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })
end

-- █▄▄ █░█ ▀█▀ ▀█▀ █▀█ █▄░█ █▀ 
-- █▄█ █▄█ ░█░ ░█░ █▄█ █░▀█ ▄█ 

--- Create a single theme button
local function create_theme_button(themename)
  local theme_button = widgets.button.text.normal({
    text = themename,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_opt_btn_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      nav_styles:remove_all_items()
      tscore:set_selected_theme(themename)
      tscore:set_selected_style("")
      theme_style_textbox:set_markup_silently("", beautiful.fg)
      select_new_theme(themename)
      -- create_style_buttons(themename)
    end
  })
  nav_themes:append(Elevated:new(theme_button))

  return wibox.widget({
    {
      theme_button,
      forced_width = dpi(200),
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  })
end

-- Creates all style buttons for a given theme
function create_style_buttons(theme)
  local function create_style_button(style)
    local style_button = widgets.button.text.normal({
      text = style,
      text_normal_bg = beautiful.fg,
      normal_bg = beautiful.switcher_opt_btn_bg,
      animate_size = false,
      size = 12,
      on_release = function()
        tscore:set_selected_style(style)
        action_buttons.visible = true
        if not nav_root:contains(nav_actions) then
          nav_root:append(nav_actions)
        end
      end
    })

    nav_styles:append(Elevated:new(style_button))

    return wibox.widget ({
      style_button,
      widget = wibox.container.place,
    })
  end

  style_buttons:reset()
  local _styles = tscore:get_themes()[theme]
  for i = 1, #_styles do
    local sbutton = create_style_button(_styles[i])
    style_buttons:add(sbutton)
  end

  if not nav_root:contains(nav_styles) then
    nav_root:append(nav_styles)
  end
end

local apply_button = wibox.widget({
  widgets.button.text.normal({
    text = "Apply",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_act_btn_bg,
    animate_size = false,
    size = 10,
    on_release = function()
      tscore:apply_selected_theme()
    end
  }),
  widget = wibox.container.place,
})

local cancel_button = wibox.widget({
  widgets.button.text.normal({
    text = "Cancel",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.switcher_act_btn_bg,
    animate_size = false,
    size = 10,
    on_release = function()
      reset_theme_switcher()
    end,
  }),
  widget = wibox.container.place,
})

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
    apply_button,
    cancel_button,
    forced_height = dpi(50),
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  },
  visible = false,
  widget = wibox.container.place,
})
nav_actions:append(Elevated:new(apply_button.children[1]))
nav_actions:append(Elevated:new(cancel_button.children[1]))

------------------------------------------

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- This is where we put all the wiboxes together and assemble the whole widget

styles = wibox.widget({
  {
    vpad(dpi(10)),
    create_themeswitch_header("Styles"),
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
    create_themeswitch_header("Themes"),
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
  wibox.widget ({
    -- "Current:" or "Selected:"
    markup = colorize("Current: ", beautiful.fg),
    font = beautiful.font_name .. "Bold",
    widget = wibox.widget.textbox,
  }),
  wibox.widget ({
    markup = colorize(tscore:get_applied_theme(), beautiful.fg),
    id = "theme_name",
    widget = wibox.widget.textbox,
  }),
  wibox.widget ({
    markup = colorize(" (" .. tscore:get_applied_style() .. ")", beautiful.fg),
    id = "theme_style",
    widget = wibox.widget.textbox,
  }),
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

local theme_switcher_contents = wibox.widget({
  {
    themes,
    styles,
    {
      selections_and_actions,
      bg = beautiful.switcher_lowbar_bg,
      widget = wibox.container.background,
    },
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.background,
  bg = beautiful.switcher_bg,
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
  widget = theme_switcher_contents,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- When tscore is finished grabbing information,
tscore:connect_signal("update::themes", function()
  themes = tscore:get_themes()
  reset_theme_switcher()
  nav_themes:remove_all_items()
  theme_buttons:reset()
  for theme in pairs(themes) do
    local tbutton = create_theme_button(theme)
    theme_buttons:add(tbutton)
  end
end)

tscore:connect_signal("updatestate::open", function()
  theme_switcher.visible = true
  navigator:start()
end)

tscore:connect_signal("updatestate::close", function()
  theme_switcher.visible = false
  reset_theme_switcher()
  navigator:stop()
end)

return function()
  return theme_switcher
end
