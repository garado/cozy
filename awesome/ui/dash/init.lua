
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local dashcore = require("core.cozy.dash")
local colorize = require("helpers.ui").colorize_text

local nav = require("modules.keynav").navigator
local area = require("modules.keynav.area")
local background = require("modules.keynav.navitem").Background

local init = false

local dash, dash_content
local switch_tab

local navigator, nav_root = nav({
  root_keys = {
    ["1"] = function() switch_tab(1) end,
    ["2"] = function() switch_tab(2) end,
    ["3"] = function() switch_tab(3) end,
    ["4"] = function() switch_tab(4) end,
    ["5"] = function() switch_tab(5) end,
    ["6"] = function() switch_tab(6) end,
  }
})

local nav_tabs = area({
  name     = "tabs",
  circular = true,
})

-- Import tab contents
local main,   nav_main     = require(... .. ".main")()
local tasks,  nav_tasks    = require(... .. ".task")()
local agenda, nav_agenda   = require(... .. ".agenda")()
local cash,   nav_cash     = require(... .. ".finances")()
local time                 = require(... .. ".time")()
local journal, nav_journal = require(... .. ".journal")()
--   local time,   nav_time    = require("ui.dash.time")()

local tablist   = { main,     tasks,      agenda,     cash,     time,   journal     }
local tabnames  = { "main",   "tasks",    "agenda",   "cash",   "time", "journal"   }
local tab_icons = { "",      "",        "",        "",      "",    ""         }
local navitems  = { nav_main, nav_tasks,  nav_agenda, nav_cash, nil,    nav_journal }

--- Display a specific tab on the dashboard
-- @param i The tab number.
function switch_tab(i)
  -- If trying to switch to the currently selected tab, do nothing
  if navitems[i] and nav_root:contains(navitems[i]) then return end

  -- Turn off highlight for all other tabs
  nav_tabs:foreach(function(tab)
    tab:select_off()
  end)

  -- Set the dash content to the proper tab
  local contents = dash_content:get_children_by_id("content")[1]
  contents:set(1, tablist[i])
  nav_root:remove_all_items()
  nav_tabs.items[i]:select_on()

  -- Insert all areas for the new tab
  if navitems[i] and not nav_root:contains(navitems[i]) then
    nav_root:append(navitems[i])
    nav_root:verify_nav_references()
  end

  nav_root:reset()
  navigator.curr_area = navigator.root

  dashcore:emit_signal("tabswitch", tabnames[i])
end

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

  for _, v in ipairs(tab_icons) do
    local tabwidget = wibox.widget({
      {
        markup = colorize(v, beautiful.fg),
        align  = "center",
        valign = "center",
        font   = beautiful.base_small_font,
        widget = wibox.widget.textbox,
      },
      bg     = beautiful.dash_tab_bg,
      widget = wibox.container.background,
    })

    local navtab = background({
      widget = tabwidget,
      bg_on  = beautiful.bg_l2,
    })

    nav_tabs:append(navtab)
    tab_bar.children[1]:add(tabwidget)
  end

  return tab_bar
end

dash_content = wibox.widget({
  {
    {
      id = "content",
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.margin,
    margins = dpi(10),
  },
  bg      = beautiful.dash_bg,
  shape   = gears.shape.rect,
  widget  = wibox.container.background,
})

-- Start off with main
dash_content:get_children_by_id("content")[1]:add(main)

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

dashcore:connect_signal("updatestate::open", function()
  dash.visible = true
  navigator:start()
  dashcore:emit_signal("newstate::opened")

  -- Ledger arc chart animation needs tabswitch signal to trigger
  if not init then
    switch_tab(1)
    init = true
  end
end)

dashcore:connect_signal("updatestate::close", function()
  dash.visible = false
  navigator:stop()
  dashcore:emit_signal("newstate::closed")
end)

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▀▀ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ██▄ 
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
    create_tab_bar(),
    dash_content,
    layout = wibox.layout.align.horizontal,
  }),
})

return function(_) return dash end
