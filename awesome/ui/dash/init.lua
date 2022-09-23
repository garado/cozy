
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")

local area = require("modules.keynav.area")
local dashtab = require("modules.keynav.navitem").Dashtab
local nav = require("modules.keynav").navigator

local navigator, nav_root = nav:new()

local nav_tabs = area:new({
  name = "tabs",
  circular = true,
})

nav_root:append(nav_tabs)

return function(s)
  local dash

  -- import tab contents
  local main, nav_main   = require("ui.dash.main")()
  local cash, nav_cash   = require("ui.dash.finances")()
  local tasks, nav_tasks = require("ui.dash.tasks")()
  local agenda = require("ui.dash.agenda")

  local tablist =   { main, cash, tasks,  agenda }
  local tab_icons = { "",  "",      "",    ""    }
  local navitems =  { nav_main, nav_cash,  nav_tasks,    nil    }

  local dash_content = wibox.widget({
    {
      {
        id = "content",
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.margin,
      margins = dpi(10),
    },
    bg = beautiful.dash_bg,
    shape = gears.shape.rect,
    widget = wibox.container.background,
  })

  local function create_tab_bar()
    local tab_bar = wibox.widget({
      {
        layout = wibox.layout.flex.vertical,
      },
      forced_width = dpi(50),
      forced_height = dpi(1400),
      shape = gears.shape.rect,
      widget = wibox.container.background,
      bg = beautiful.dash_tab_bg,
    })

    for i,v in ipairs(tab_icons) do
      local widget
      widget = widgets.button.text.normal({
        text = v,
        text_normal_bg = beautiful.fg,
        normal_bg = beautiful.dash_tab_bg,
        animate_size = false,
        size = 15,
        on_release = function()
          local contents = dash_content:get_children_by_id("content")[1]
          contents:set(1, tablist[i])
          nav_root:remove_all_except_item(nav_tabs)

          -- insert all areas for the new tab
          if navitems[i] and not nav_root:contains(navitems[i]) then
            nav_root:append(navitems[i])
          end
        end
      })
      nav_tabs:append(dashtab:new(widget))
      tab_bar.children[1]:add(widget)
    end

    return tab_bar
  end

  local tab_bar = create_tab_bar()

  -- Start off with main
  dash_content:get_children_by_id("content")[1]:add(main)

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  awesome.connect_signal("dash::toggle", function()
    if dash.visible then
      awesome.emit_signal("dash::closed")
      nav_root:reset()
      navigator:stop()
    else
      require("ui.shared").close_other_popups("dash")
      awesome.emit_signal("dash::opened")
      navigator:start()
    end
    dash.visible = not dash.visible
  end)

  awesome.connect_signal("dash::open", function()
    dash.visible = true
    awesome.emit_signal("dash::opened")
  end)

  awesome.connect_signal("dash::close", function()
    dash.visible = false
    awesome.emit_signal("dash::closed")
  end)

  -- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▀▀ 
  -- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ██▄ 
  local swidth = s.geometry.width
  local sheight = s.geometry.height
  dash = awful.popup({
    type = "splash",
    minimum_height = dpi(810),
    maximum_height = dpi(810),
    minimum_width = dpi(1350), -- 70% of screen
    maximum_width = dpi(1350),
    bg = beautiful.transparent,
    ontop = true,
    visible = false,
    placement = awful.placement.centered,
    widget = ({
      tab_bar,
      dash_content,
      layout = wibox.layout.align.horizontal,
    }),
  })

  nav_root:append(nav_main)
  --local main_tab_icon = tab_bar.children[1].children[1]
  --main_tab_icon:set_color(beautiful.main_accent)
end
