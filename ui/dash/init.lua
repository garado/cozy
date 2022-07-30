
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")
local helpers = require("helpers")

return function(s) 
  -- import tab contents
  cal = require("ui.dash.cal")(s)
  habit = require("ui.dash.habit")(s)
  main = require("ui.dash.main")(s)
  todo = require("ui.dash.todo")(s)
  weather = require("ui.dash.weather")(s)
  
  -- decide which tab to show
  local active_tab = "main"
  local tab = main
  tablist = {"main", "todo", "cal", "weather", "habit"}
  for t in ipairs(tablist) do
    if active_tab == t then
      tab = t
    end 
  end

  -- create tabs
  local function new_tab(name)
    return wibox.widget({
      {
        {
          {
            markup = helpers.ui.colorize_text(name, beautiful.xforeground),
            widget = wibox.widget.textbox,
          },
          widget = wibox.container.place,
        },
        forced_height = dpi(100),
        forced_width = dpi(30),
        shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true)
        end,
        id = name, -- change bg of active/inactive tabs
        bg = beautiful.dash_tab_bg,
        widget = wibox.container.background,
      },
      margins = { top = dpi(5), bottom = dpi(5) },
      widget = wibox.container.margin,
    })
  end

  -- toggle visibility
  awesome.connect_signal("dash::toggle", function(scr)
    s.dash.visible = not s.dash.visible
  end)

  -- DASH KEYBOARD NAVIGATION
  -- "cursor" is either in tabs or content
  local group_selected = "tab"
  local obj_selected = "user"

  -- ugh
  local function navigate()
    --navigate_dash = awful.keygrabber(
    --  function(_, key, event)
    --    if key == 'release' then
    --      awful.keygrabber.stop(navigate_dash)
    --      return
    --    end

    --    if key == 'h' then
    --      active_tab = "todo"
    --    elseif key == 'l' then
    --      active_tab = "weather"
    --    elseif key == 'g' then
    --      awful.keygrabber.stop(navigate_dash)
    --    else
    --      awful.keygrabber.stop(navigate_dash)
    --    end
    --  end
    --)
  end

  -- build dashboard
  s.dash = awful.popup({
    type = "dock",
    screen = s,
    minimum_height = dpi(800),
    maximum_height = dpi(800),
    minimum_width = dpi(1400),
    maximum_width = dpi(1400),
    bg = beautiful.transparent,
    ontop = true,
    visible = false,
    placement = awful.placement.centered,
    widget = {
      {
        {
          new_tab("M"), -- idk how to generate these from the tablist
          new_tab("T"),
          new_tab("C"),
          new_tab("H"),
          new_tab("W"),
          layout = wibox.layout.fixed.vertical,
        },
        top = dpi(20),
        widget = wibox.container.margin,
      }, -- end tabs
      {
        {
          tab,
          widget = wibox.container.margin,
          margins = dpi(10),
        },
        bg = beautiful.dash_bg,
        shape = gears.shape.rounded_rect,
        widget = wibox.container.background,
      }, -- end content
      layout = wibox.layout.align.horizontal,
      -- UGH!!!
      -- callback = function()
      --   navigate()
      -- end
    } -- end widget
  })

end
