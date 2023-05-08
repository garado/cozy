
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local ts    = require("backend.state.themeswitch")
local sbg   = require("frontend.widget.stateful-button-group")
local btn   = require("frontend.widget.button")

local themeswitcher = {}

-- Theme selection
local themes_header = ui.textbox({
  text  = "Themes",
  align = "center",
  font  = beautiful.font_med_m,
})

local themes_sbg = sbg({
  layout  = "vertical",
  spacing = dpi(12),
  shape   = ui.rrect(8),
  group_bg = beautiful.neutral[900],
  set_no_shape = false,
  autoselect_first = false,
})

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

local styles_sbg = sbg({
  spacing = dpi(12),
  shape   = ui.rrect(8),
  group_bg = beautiful.neutral[900],
  set_no_shape = false,
  autoselect_first = false,
})

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

-- Apply/cancel action buttons
local actions = wibox.widget({
  {
    {
      btn({
        text = "Apply",
        func = function() ts:apply() end,
        bg    = beautiful.neutral[700],
        bg_mo = beautiful.neutral[600],
      }),
      btn({
        text = "Cancel",
        func = function() themeswitcher:reset() end,
        bg    = beautiful.neutral[700],
        bg_mo = beautiful.neutral[600],
      }),
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
    bg = beautiful.neutral[900],
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
  bg = beautiful.neutral[900],
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = content,
})



-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 

function themeswitcher:reset()
  styles_sbg:reset()
  styles.visible  = false
  actions.visible = false
end

ts:connect_signal("ready::themes", function()
  for i = 1, #ts.themes do
    themes_sbg:add_btn(ts.themes[i])
  end
end)

themes_sbg:connect_signal("child::press", function(self, idx)
  ts.selected_theme = self:get_name_at_idx(idx)
  ts.selected_style = nil
  styles_sbg:reset()
  actions.visible = false
  ts:fetch_styles(ts.selected_theme)
end)

ts:connect_signal("ready::styles", function()
  styles_sbg:reset()
  styles.visible = true
  for i = 1, #ts.styles do
    styles_sbg:add_btn(ts.styles[i])
  end
end)

styles_sbg:connect_signal("child::press", function(self, idx)
  ts.selected_style = self:get_name_at_idx(idx)
  actions.visible = true
end)

ts:connect_signal("setstate::open", function()
  themeswitcher.visible = true
  ts:emit_signal("newstate::opened")
end)

ts:connect_signal("setstate::close", function()
  themeswitcher.visible = false
  ts:emit_signal("newstate::closed")
end)

return function(_) return themeswitcher end
