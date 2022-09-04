
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local keygrabber = require("awful.keygrabber")
local naughty = require("naughty")

-- import widgets
local profile = require("ui.control_center.profile")
local quick_actions = require("ui.control_center.quick_actions") local uptime = require("ui.control_center.uptime")
local power_options = require("ui.control_center.power_options")
local links = require("ui.control_center.links")

return function(s)
  local screen_height = dpi(s.geometry.height)
  local screen_width = dpi(s.geometry.width)

  -- assemble the control center
  local control_center_contents = wibox.widget({
    {
        { -- body
          {
            quick_actions,
            links,
            spacing = dpi(20),
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(25),
          widget = wibox.container.margin,
        }, -- end body
        { -- lower tab
          {
            { -- left (uptime)
              {
                uptime,
                widget = wibox.container.place,
              },
              margins = dpi(15),
              widget = wibox.container.margin,
            }, -- end left
            nil,
            { -- right
              power_options,
              layout = wibox.layout.fixed.horizontal,
            }, -- end right
            forced_height = dpi(50),
            layout = wibox.layout.align.horizontal,
          },
          bg = beautiful.ctrl_lowerbar_bg,
          widget = wibox.container.background,
        }, -- end lower tab
        layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  })

  local control_center_width = dpi(500)
  local control_center = awful.popup ({
    type = "popup_menu",
    minimum_height = control_center_height,
    maximum_height = control_center_height,
    minimum_width = control_center_width,
    maximum_width = control_center_width,
    placement = awful.placement.centered,
    bg = beautiful.transparent,
    shape = gears.shape.rect,
    ontop = true,
    visible = false,
    widget = control_center_contents,
  })

  -- CTRL CENTER KEYBOARD NAVIGATION
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

  -- keybindings to navigate control center
  local function navigate()
    --local content = dash_content:get_children_by_id("content")[1]

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

    -- Call functions depending on which key was pressed
    local function keypressed(self, mod, key, command)
      local naughty = require("naughty")
      naughty.notification { message = key } 
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
    local ctrl_keygrabber = awful.keygrabber {
      stop_key = "Mod4",
      stop_event = "press",
      autostart = true,
      timeout = 10,
      keypressed_callback = keypressed,
    }
  end

  -- Keybind to toggle (default is Super_L + k)
  awesome.connect_signal("control_center::toggle", function()
    control_center.visible = not control_center.visible
    --if control_center.visible == true then
    --  navigate()
    --end
  end)

  return control_center
end


