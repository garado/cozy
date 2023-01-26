
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
local keynav   = require("modules.keynav")
local config   = require("cozyconf")

local exclude_tabs = config.exclude_dash_tabs

local tabs, dash_content, switch_tab
local init = false

local navigator, nav_root = keynav.navigator({
  root_keys = {
    ["1"] = function() switch_tab(1) end,
    ["2"] = function() switch_tab(2) end,
    ["3"] = function() switch_tab(3) end,
    ["4"] = function() switch_tab(4) end,
    ["5"] = function() switch_tab(5) end,
    ["6"] = function() switch_tab(6) end,
  }
})

local main,   nav_main     = require(... .. ".main")()
local tasks,  nav_tasks    = require(... .. ".task")()
local agenda, nav_agenda   = require(... .. ".agenda")()
local cash,   nav_cash     = require(... .. ".finances")()
local time                 = require(... .. ".time")()
local journal, nav_journal = require(... .. ".journal")()
--   local time,   nav_time    = require(... .. ".time")()

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
  for j = 1, #tabs.children do
    tabs.children[j]:select_off()
  end

  nav_root:reset()

  -- Set the dash content to the proper tab
  local contents = dash_content:get_children_by_id("content")[1]
  contents:set(1, tablist[i])
  tabs.children[i]:select_on()

  -- Insert all areas for the new tab
  if navitems[i] and not nav_root:contains(navitems[i]) then
    nav_root:append(navitems[i])
    nav_root:verify_nav_references()
  end

  navigator.curr_area = navigator.root

  dashcore:emit_signal("tabswitch", tabnames[i])
end


-- ▀█▀ ▄▀█ █▄▄    █▄▄ ▄▀█ █▀█ 
-- ░█░ █▀█ █▄█    █▄█ █▀█ █▀▄ 

local pfp = wibox.widget({
  {
    {
      {
        image  = beautiful.pfp,
        resize = true,
        forced_height = dpi(28),
        forced_width  = dpi(28),
        widget = wibox.widget.imagebox,
      },
      bg     = beautiful.main_accent,
      shape  = gears.shape.circle,
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  },
  top    = dpi(10),
  widget = wibox.container.margin,
})

local distro = wibox.widget({
  {
    {
      markup = colorize(config.distro_icon, beautiful.main_accent),
      align  = "center",
      valign = "center",
      font   = beautiful.base_small_font,
      widget = wibox.widget.textbox,
    },
    widget = wibox.container.place,
  },
  bottom = dpi(12),
  widget = wibox.container.margin,
})

local tabbar = wibox.widget({
  {
    pfp,
    nil,
    distro,
    layout = wibox.layout.align.vertical,
  },
  forced_width  = dpi(50),
  forced_height = dpi(1400),
  shape  = gears.shape.rect,
  bg     = beautiful.dash_tab_bg,
  widget = wibox.container.background,
})

tabs = wibox.widget({
  layout  = wibox.layout.fixed.vertical,
})

for i = 1, #tab_icons do
  local tab = wibox.widget({
    { -- bg + icon
      {
        markup = colorize(tab_icons[i], beautiful.fg),
        align  = "center",
        valign = "center",
        forced_height = dpi(60),
        font   = beautiful.base_small_font,
        widget = wibox.widget.textbox,
      },
      id = "bg",
      widget = wibox.container.background,
    },
    { -- vbar
      {
        forced_width = dpi(2),
        -- bg     = beautiful.fg,
        widget = wibox.container.background,
      },
      id     = "vbar",
      right  = dpi(47),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  })

  function tab:select_on()
    local vbar = tab:get_children_by_id("vbar")[1].children[1]
    local bg = tab:get_children_by_id("bg")[1]
    vbar.bg = beautiful.fg
    bg.bg   = beautiful.bg_l2
  end

  function tab:select_off()
    local vbar = tab:get_children_by_id("vbar")[1].children[1]
    local bg   = tab:get_children_by_id("bg")[1]
    vbar.bg = nil
    bg.bg   = nil
  end

  tabs:add(tab)
end

tabbar.children[1].second = wibox.widget({
  tabs,
  widget = wibox.container.place,
})

dash_content = wibox.widget({
  {
    {
      id = "content",
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(10),
    widget  = wibox.container.margin,
  },
  bg      = beautiful.dash_bg,
  shape   = gears.shape.rect,
  widget  = wibox.container.background,
})

-- Start off with main
dash_content:get_children_by_id("content")[1]:add(main)

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▀▀ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ██▄ 
local dash = awful.popup({
  type = "splash",
  minimum_height = dpi(810),
  maximum_height = dpi(810),
  minimum_width  = dpi(1350), -- 70% of screen
  maximum_width  = dpi(1350),
  bg = beautiful.transparent,
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = ({
    tabbar,
    dash_content,
    layout = wibox.layout.align.horizontal,
  }),
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

dashcore:connect_signal("setstate::open", function()
  dash.visible = true
  navigator:start()
  dashcore:emit_signal("newstate::opened")

  -- Ledger arc chart animation needs tabswitch signal to trigger
  if not init then
    switch_tab(1)
    init = true
  end
end)

dashcore:connect_signal("setstate::close", function()
  dash.visible = false
  navigator:stop()
  dashcore:emit_signal("newstate::closed")
end)


return function(_) return dash end
