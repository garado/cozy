
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local ts    = require("backend.cozy.themeswitch")
local ss    = require("frontend.widget.single-select")
local btn  = require("frontend.widget.button")
local sbtn  = require("frontend.widget.button")
local keynav = require("modules.keynav")
local beautiful  = require("beautiful")

local navigator, nav_root = keynav.navigator()

local themeswitcher = {}

-- Theme selection
local themes_header = ui.textbox({
  text  = "Themes",
  align = "center",
  font  = beautiful.font_med_m,
})

local themes_sbg = ss({
  spacing = dpi(12),
  layout  = wibox.layout.fixed.vertical,
  ---
  keynav = true,
  name = "nav_themes"
})

nav_root:append(themes_sbg.area)

local themes = wibox.widget({
  {
    themes_header,
    themes_sbg,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

-- Style selection
local styles_header = ui.textbox({
  text  = "Styles",
  align = "center",
  font  = beautiful.font_med_m,
})

local styles_sbg = wibox.widget({
  spacing = dpi(12),
  forced_height = dpi(40),
  layout  = wibox.layout.fixed.horizontal,
})

styles_sbg = ss({
  layout = styles_sbg,
  keynav = true,
  name = "nav_styles"
})
nav_root:append(styles_sbg.area)

local styles = wibox.widget({
  ui.vpad(dpi(25)),
  {
    {
      styles_header,
      styles_sbg,
      spacing = dpi(10),
      layout  = wibox.layout.fixed.vertical,
    },
    widget  = wibox.container.place,
  },
  visible = false,
  layout = wibox.layout.fixed.vertical,
})


-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

local apply_btn = btn({
  text  = "Apply",
  func  = function()
    ts:apply()
    themeswitcher:reset()
  end,
  bg    = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
})

local cancel_btn = btn({
  text  = "Cancel",
  func  = function() themeswitcher:reset() end,
  bg    = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
})

local nav_actions = keynav.area({
  name = "nav_actions",
})
nav_root:append(nav_actions)

local actions = wibox.widget({
  {
    {
      apply_btn,
      cancel_btn,
      spacing = dpi(10),
      layout  = wibox.layout.fixed.horizontal,
    },
    widget  = wibox.container.place,
  },
  visible = false,
  margins = dpi(12),
  widget  = wibox.container.margin,
})

-- Assemble final widget
local content = wibox.widget({
  {
    {
      {
        themes,
        styles,
        layout  = wibox.layout.fixed.vertical,
      },
      top     = dpi(20),
      bottom  = dpi(20),
      left    = dpi(10),
      right   = dpi(10),
      widget  = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  },
  {
    actions,
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  },
  layout = wibox.layout.fixed.vertical,
})

themeswitcher = awful.popup({
  type = "splash",
  minimum_width  = dpi(330),
  maximum_width  = dpi(330),
  shape = ui.rrect(),
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = content,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

function themeswitcher:reset()
  -- UI
  styles_sbg:reset()
  styles.visible  = false
  actions.visible = false

  -- Keynav
  styles_sbg.area:clear()
  nav_actions:clear()
  nav_root:set_active_element_by_index(1)
  navigator.focused_area = nav_root
end

ts:connect_signal("ready::themes", function()
  for i = 1, #ts.themes do
    local s = sbtn({
      text = ts.themes[i],
      bg    = beautiful.neutral[700],
      bg_mo = beautiful.neutral[600],
      on_release = function(self)
        ts.selected_theme = self.name
        ts.selected_style = nil
        styles_sbg:reset()
        actions.visible = false
        ts:fetch_styles(ts.selected_theme)
      end
    })
    s.name = ts.themes[i]
    themes_sbg:add_element(s)
  end
end)

ts:connect_signal("ready::styles", function()
  styles_sbg:reset()
  styles.visible = true
  for i = 1, #ts.styles do
    local s = sbtn({
      text = ts.styles[i],
      bg    = beautiful.neutral[700],
      bg_mo = beautiful.neutral[600],
      on_release = function(self)
        ts.selected_style = self.name
        nav_actions:clear()
        nav_actions:append(apply_btn)
        nav_actions:append(cancel_btn)
        actions.visible = true
      end
    })
    s.name = ts.styles[i]
    styles_sbg:add_element(s)
  end
end)

ts:connect_signal("setstate::open", function()
  navigator:start()
  themeswitcher.visible = true
  ts:emit_signal("newstate::opened")
end)

ts:connect_signal("setstate::close", function()
  navigator:stop()
  themeswitcher.visible = false
  ts:emit_signal("newstate::closed")
end)

return function(_) return themeswitcher end
