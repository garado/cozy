
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
local widgets = require("ui.widgets")
local naughty = require("naughty")

return function(s) 
  local dash

  -- import tab contents
  local main = require("ui.dash.main")
  local finances = require("ui.dash.finances")
  local cal = require("ui.dash.cal")
  local habit = require("ui.dash.habit")
  local todo = require("ui.dash.todo")
  local weather = require("ui.dash.weather")
  local vision = require("ui.dash.dreams")
 
  -- decide which tab to show
  -- main, finances, habit, caltodo, weather, dreams,
  local tablist_pos = 1
  local tablist =   { main, finances, habit,  cal,    weather, vision}
  local tab_icons = { "",  "",    "",    "",    "盛",   "滛", }
  local tablist_elems = 7 -- ???

  -- create tabs based on tablist
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

  -------------------------
  --                     -- 
  -- ASSEMBLING THE DASH --
  --                     -- 
  -------------------------

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
    shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false)
    end,
    widget = wibox.container.background,
  })

  local function create_tab_bar()
    local tab_bar = wibox.widget({
      {
        layout = wibox.layout.flex.vertical,
      },
      forced_width = dpi(50),
      forced_height = dpi(1400),
      shape = function(cr, width, height)
          gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true)
      end,
      widget = wibox.container.background,
      bg = beautiful.dash_tab_bg,
    })

    for i,v in ipairs(tab_icons) do
      local widget = widgets.button.text.normal({
        text = v,
        text_normal_bg = beautiful.xforeground,
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

  dash_content:get_children_by_id("content")[1]:add(main)

  local ugh = wibox.widget({
   create_tab_bar(),
   dash_content,
   layout = wibox.layout.align.horizontal,
   -- UGH!!!
   -- end widget
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
      local index = ((tablist_pos + 1) % tablist_elems)
      content:set(1, tablist[index])
      tablist_pos = index
    end

    local function prev_tab()
      local index = ((tablist_pos - 1) % tablist_elems)
      content:set(1, tablist[index])
      tablist_pos = index
    end

    -- I thought about making h/l navigate between interactive
    -- tab elements (e.g. pomodoro) but then decided against it

    -- Call functions depending on which key was pressed
    local function keypressed(self, mod, key, command)
      if     key == "j" then
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
      stop_event = "release",
      autostart = true,
      allowed_keys = { "h", "j", "k", "l" },
      timeout = 3,
      keypressed_callback = keypressed,
    }
  end
  
  -- toggle visibility
  awesome.connect_signal("dash::toggle", function()
    if dash.visible then
      awesome.emit_signal("dash::close")
    else
      awesome.emit_signal("dash::open")
      navigate()
    end
    dash.visible = not dash.visible
  end)

  -- build dashboard
  dash = awful.popup({
    type = "dock",
    --screen = s,
    minimum_height = dpi(810),
    maximum_height = dpi(810),
    minimum_width = dpi(1400),
    maximum_width = dpi(1400),
    bg = beautiful.transparent,
    ontop = true,
    visible = false,
    placement = awful.placement.centered,
    widget = ugh,
  })

end
