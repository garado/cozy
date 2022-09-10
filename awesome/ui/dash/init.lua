
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")
local widgets = require("ui.widgets")
local naughty = require("naughty")

return function(s) 
  local dash

  -- import tab contents
  local main = require("ui.dash.main")
  local finances = require("ui.dash.finances")
  local habit = require("ui.dash.habit")
  local agenda = require("ui.dash.agenda")

  local tablist =   { main, finances, habit,  agenda }
  local tab_icons = { "",  "",      "",    ""    }
  local tablist_pos = 1
  local tablist_elems = 4

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
          tablist_pos = i
        end
      })
      tab_bar.children[1]:add(widget)
    end

    return tab_bar
  end

  local tab_bar = create_tab_bar()

  dash_content:get_children_by_id("content")[1]:add(main)

  local ugh = wibox.widget({
    tab_bar,
    dash_content,
    layout = wibox.layout.align.horizontal,
  })

  -- DASH KEYBOARD NAVIGATION
  -- "cursor" is either in tabs or content
  local group_selected = "tab"
  local obj_selected = "user"

  local function dbn(message)
    naughty.notification {
      app_name = "custom keygrabber",
      title = "navigate()",
      message = message,
      timeout = 1,
    }
  end

  -- Vim-like keybindings to navigate dash!
  local function navigate()
    local content = dash_content:get_children_by_id("content")[1]

    -- "j" and "k" navigate between tabs
    local function next_tab()
      local old_index = tablist_pos
      local index = ((tablist_pos + 1) % tablist_elems)
      if index == 0 then index = 4 end
      content:set(1, tablist[index])
      tablist_pos = index

      local tab = tab_bar.children[1].children[tablist_pos]
      tab:set_color(beautiful.main_accent)
      local prev_tab = tab_bar.children[1].children[old_index]
      prev_tab:set_color(beautiful.fg)
    end

    local function prev_tab()
      local old_index = tablist_pos
      local index = ((tablist_pos - 1) % tablist_elems)
      if index == 0 then index = 4 end
      content:set(1, tablist[index])
      tablist_pos = index

      local tab = tab_bar.children[1].children[tablist_pos]
      tab:set_color(beautiful.main_accent)
      local prev_tab = tab_bar.children[1].children[old_index]
      prev_tab:set_color(beautiful.fg)
    end

    -- I thought about making h/l navigate between interactive
    -- tab elements (e.g. pomodoro) but then decided against it

    -- Call functions depending on which key was pressed
    local function keypressed(self, mod, key, command)
      if key == "j" then
        next_tab()
      elseif key == "k" then
        prev_tab()
      --elseif key == "h" then
      --  prev_element()
      --elseif key == "l" then
      --  next_element()
      end
    end

    -- Putting all the puzzle pieces together
    local dash_keygrabber = awful.keygrabber {
      stop_key = "Mod4",
      stop_event = "press",
      autostart = true,
      timeout = 10,
      keypressed_callback = keypressed,
    }
  end

  -- toggle visibility
  awesome.connect_signal("dash::toggle", function()
    if dash.visible then
      awesome.emit_signal("dash::closed")
    else
      awesome.emit_signal("dash::opened")
      navigate()
      awesome.emit_signal("control_center::close")
      awesome.emit_signal("settings::close")
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

  -- build dashboard
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
    widget = ugh,
  })
      
  local main_tab_icon = tab_bar.children[1].children[1]
  main_tab_icon:set_color(beautiful.main_accent)

end
