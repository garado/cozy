
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")

local Box = require("ui.nav.box")
local elevated = require("ui.nav.navclass").Elevated
local navigate = require("ui.dash.navigate")

local nav_root = Box:new({
  name = "root",
  is_circular = true,
})

local nav_tabs = Box:new({ name = "tabs" })
nav_root:append(nav_tabs)

return function()
  local dash

  -- import tab contents
  local main, nav_main = require("ui.dash.main")()
  nav_root:append(nav_main)

  local finances = require("ui.dash.finances")
  local habit = require("ui.dash.habit")
  local agenda = require("ui.dash.agenda")

  local tablist =   { main, finances, habit,  agenda }
  local tab_icons = { "",  "",      "",    ""    }

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
      local widget = widgets.button.text.normal({
        text = v,
        text_normal_bg = beautiful.fg,
        normal_bg = beautiful.dash_tab_bg,
        animate_size = false,
        size = 15,
        on_release = function()
          local fuck = dash_content:get_children_by_id("content")[1]
          fuck:set(1, tablist[i])
        end
      })
      nav_tabs:append(elevated:new(widget))
      tab_bar.children[1]:add(widget)
    end

    return tab_bar
  end

  local tab_bar = create_tab_bar()
  dash_content:get_children_by_id("content")[1]:add(main)

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  awesome.connect_signal("dash::toggle", function()
    if dash.visible then
      awesome.emit_signal("dash::closed")
    else
      require("ui.shared").close_other_popups("dash")
      awesome.emit_signal("dash::opened")
      navigate:start(nav_root)
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
  dash = awful.popup({
    type = "splash",
    minimum_height = dpi(810),
    maximum_height = dpi(810),
    minimum_width = dpi(1350),
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

  local main_tab_icon = tab_bar.children[1].children[1]
  main_tab_icon:set_color(beautiful.main_accent)
end
