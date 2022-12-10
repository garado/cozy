
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")
local dashcore = require("core.cozy.dash")
local area = require("modules.keynav.area")
local dashtab = require("modules.keynav.navitem").Dashtab
local nav = require("modules.keynav").navigator

local navigator, nav_root = nav:new()

local nav_tabs = area:new({
  name = "tabs",
  circular = true,
})

return function(_) -- s
  local dash, dash_content

  -- Import tab contents
  local main,   nav_main    = require("ui.dash.main")()
  local cash,   nav_cash    = require("ui.dash.finances")()
  local tasks,  nav_tasks   = require("ui.dash.tasks")()
  local time                = require("ui.dash.time")()
--  local time,   nav_time    = require("ui.dash.time")()
  local agenda = require("ui.dash.agenda")

  local tablist =   { main, tasks, time, cash,  agenda }
  local tab_icons = { "",  "",   "",  "",   ""    }
  local navitems =  { nav_main, nav_tasks, nil, nav_cash, nil }

  --- Display a specific tab on the dashboard
  -- @param i The tab number.
  local function switch_tab(i)
    -- If trying to switch to the currently selected tab, 
    -- do nothing
    if navitems[i] and nav_root:contains(navitems[i]) then return end

    -- Turn off highlight for all other tabs
    nav_tabs:foreach(function(tab)
      tab.widget:nav_hl_off()
    end)

    -- Set the dash content to the proper tab
    local contents = dash_content:get_children_by_id("content")[1]
    contents:set(1, tablist[i])
    nav_root:remove_all_items()
    nav_tabs.items[i].widget:nav_hl_on()

    -- Insert all areas for the new tab
    if navitems[i] and not nav_root:contains(navitems[i]) then
      nav_root:append(navitems[i])
      nav_root:verify_nav_references()
    end

    nav_root:reset()
    navigator.curr_area = navigator.root
  end

  nav_root.keys = {
    ["1"] = {["function"] = switch_tab, ["args"] = 1},
    ["2"] = {["function"] = switch_tab, ["args"] = 2},
    ["3"] = {["function"] = switch_tab, ["args"] = 3},
    ["4"] = {["function"] = switch_tab, ["args"] = 4},
    ["5"] = {["function"] = switch_tab, ["args"] = 5},
  }

  dash_content = wibox.widget({
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
          switch_tab(i)
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
  -- Emitted by keybind to open dash.
  -- dashcore:connect_signal("updatestate::toggle", function()
  --   if dash.visible then
  --     navigator:stop()
  --   else
  --     require("ui.shared").close_other_popups("dash")
  --     dashcore:emit_signal("newstate::opened")
  --     navigator:start()
  --   end
  --   dash.visible = not dash.visible
  -- end)

  dashcore:connect_signal("updatestate::open", function()
    dash.visible = true
    navigator:start()
    dashcore:emit_signal("newstate::opened")
  end)

  dashcore:connect_signal("updatestate::close", function()
    dash.visible = false
    navigator:stop()
    dashcore:emit_signal("newstate::closed")
  end)

  -- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▀▀ 
  -- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ██▄ 
  -- local swidth = s.geometry.width
  -- local sheight = s.geometry.height
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

  switch_tab(1)
end
