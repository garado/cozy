
-- █░░ ▄▀█ █▄█ █▀█ █░█ ▀█▀    █░░ █ █▀ ▀█▀ 
-- █▄▄ █▀█ ░█░ █▄█ █▄█ ░█░    █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers.ui").colorize_text
local dpi = require("beautiful.xresources").apply_dpi

return function()
 local ll = awful.widget.layoutlist {
    base_layout = wibox.widget {
      spacing         = 5,
      forced_num_cols = 5,
      layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
      {
        {
          id            = 'icon_role',
          forced_height = dpi(30),
          forced_width  = dpi(30),
          widget        = wibox.widget.imagebox,
        },
        margins = dpi(5),
        widget  = wibox.container.margin,
      },
      id              = 'background_role',
      bg              = beautiful.layout_bg,
      forced_width    = dpi(35),
      forced_height   = dpi(35),
      shape           = gears.shape.rounded_rect,
      widget          = wibox.container.background,
    },
  }

  local title = wibox.widget({
    markup = colorize("Layout name", beautiful.fg),
    font = beautiful.font_name .. "15",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local layout_popup = awful.popup {
    widget = wibox.widget {
      {
        {
          title,
          {
            ll,
            widget = wibox.container.place,
          },
          spacing = dpi(5),
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.place,
      },
      margin = dpi(20),
      forced_height = dpi(80),
      forced_width = dpi(250),
      widget = wibox.container.margin,
    },
    border_color = beautiful.border_color,
    placement    = awful.placement.centered,
    ontop        = true,
    visible      = false,
    shape        = gears.shape.rounded_rect,
    type         = "splash"
  }

  local function set_title()
    local lname = awful.layout.get()["name"]
    title:set_markup_silently(colorize(lname, beautiful.fg))
  end

  local function set_icon_color(index, color)
    -- find the icon and recolor it
    local lname = awful.layout.get()["name"]
    local icon = beautiful["layout_"..lname]
    local icon_recolored = gears.color.recolor_image(icon, color)

    -- find the currently selected icon in the layout list and replace icon
    local ll_icons = ll._private.layout:get_children()
    local img = ll_icons[index]:get_children_by_id("icon_role")[1]
    if icon_recolored and img then img.image = icon_recolored end
  end

  local function update_layoutlist_ui(first_keypress, iter)
    -- stop first keypress from cycling layout
    if first_keypress then iter = 0 end

    local layout, index = gears.table.cycle_value(ll.layouts, ll.current_layout, iter)
    awful.layout.set(layout)
    set_title()
    set_icon_color(index, beautiful.main_accent)
  end

  -- █▄▀ █▀▀ █▄█ █▀▀ █▀█ ▄▀█ █▄▄ █▄▄ █▀▀ █▀█ 
  -- █░█ ██▄ ░█░ █▄█ █▀▄ █▀█ █▄█ █▄█ ██▄ █▀▄ 
  local mod = "Mod4"
  local first_keypress = true
  awful.keygrabber {
    start_callback = function()
      layout_popup.visible = true
      first_keypress = true
    end,
    stop_callback  = function() layout_popup.visible = false end,
    export_keybindings = true,
    stop_event = "release",
    stop_key = {"Escape", "Super_L", "Super_R"},
    keybindings = {
      {{ mod } , " " , function()
        update_layoutlist_ui(first_keypress, 1)
        first_keypress = false
      end},
      {{ mod, "Shift" } , " " , function()
        update_layoutlist_ui(first_keypress, -1)
        first_keypress = false
      end},
    }
  }
end
