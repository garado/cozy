
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")

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
        markup = name,
        widget = wibox.widget.textbox,
      },
      bg = beautiful.background_med,
      widget = wibox.container.background,
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
    minimum_width = dpi(1200),
    maximum_width = dpi(1200),
    bg = beautiful.background_dark,
    ontop = true,
    visible = false,
    placement = awful.placement.centered,
    widget = {
      {
        new_tab("main"), -- idk how to generate these from the tablist
        new_tab("todo"),
        new_tab("cal"),
        new_tab("habit"),
        new_tab("weather"),
        layout = wibox.layout.fixed.vertical,
        widget = wibox.container.margin,
      }, -- end tabs
      {
        tab,
        layout = wibox.layout.fixed.vertical,
      }, -- end content
      layout = wibox.layout.align.horizontal,
      -- callback = function()
      --   navigate()
      -- end
    } -- end widget
  })

end
