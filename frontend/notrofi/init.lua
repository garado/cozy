
-- █▄░█ █▀█ ▀█▀    █▀█ █▀█ █▀▀ █ 
-- █░▀█ █▄█ ░█░    █▀▄ █▄█ █▀░ █ 

-- It's not Rofi, but it's Rofi.
-- https://github.com/adi1090x/rofi/ (Type 7 Img 10)

-- Window switcher and app launcher with implementation heavily inspired by
-- bling's but trimmed down and with modified UI to suit my aesthetic.

local beautiful  = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local notrofi = require("backend.cozy.notrofi")

local launcher = require(... .. ".launcher")
local switcher = require(... .. ".switcher")

local content = launcher
local LAUNCHER, SWITCHER = 1, 2
local active_opt = LAUNCHER
local last_key = ""

local img = wibox.widget({
  image = beautiful.accent_image,
  resize = true,
  forced_width = dpi(200),
  widget = wibox.widget.imagebox,
})

local promptbox = wibox.widget({
  text = "Search",
  font = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
})

local promptbox_colorized = wibox.container.background()
promptbox_colorized:set_widget(promptbox)
promptbox_colorized:set_fg(beautiful.neutral[100])

local search = wibox.widget({
  { -- Icon
    {
      ui.textbox({
        text = "",
        align = "center",
      }),
      margins = dpi(8),
      widget = wibox.container.margin,
    },
    shape = ui.rrect(),
    bg = beautiful.neutral[600],
    widget = wibox.container.background,
  },
  { -- Searchbar
    {
      promptbox_colorized,
      margins = dpi(8),
      widget = wibox.container.margin,
    },
    shape = ui.rrect(),
    bg = beautiful.neutral[600],
    forced_width = dpi(200),
    widget = wibox.container.background,
  },
  spacing = dpi(4),
  layout = wibox.layout.fixed.horizontal,
})

local opt_launcher = wibox.widget({
  {
    ui.textbox({ text = "󰀻", align = "center" }),
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  shape = ui.rrect(),
  bg = beautiful.primary[700],
  widget = wibox.container.background,
  ------
  set_active = function(self)
    self.bg = beautiful.primary[700]
  end,
  set_inactive = function(self)
    self.bg = beautiful.neutral[600]
  end,
})

local opt_switcher = wibox.widget({
  {
    ui.textbox({ text = "", align = "center" }),
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  shape = ui.rrect(),
  bg = beautiful.neutral[600],
  widget = wibox.container.background,
  ------
  set_active = function(self)
    self.bg = beautiful.primary[700]
  end,
  set_inactive = function(self)
    self.bg = beautiful.neutral[600]
  end,
})

local options = wibox.widget({
  {
    {
      opt_launcher,
      opt_switcher,
      spacing = dpi(8),
      layout = wibox.layout.flex.horizontal,
    },
    margins = dpi(10),
    widget = wibox.container.margin,
  },
  bg = beautiful.neutral[800],
  widget = wibox.container.background,
})

local widget = wibox.widget({
  {
    img,
    ui.place(search),
    widget = wibox.layout.stack,
  },
  {
    {
      content,
      top   = dpi(10),
      left  = dpi(10),
      right = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  },
  options,
  layout = wibox.layout.fixed.vertical,
  -----
  set_content = function(self, c)
    self.children[2].widget.widget = c
  end,
})

local nrofi = awful.popup({
  type          = "splash",
  minimum_width = dpi(450),
  maximum_width = dpi(450),
  bg            = beautiful.neutral[900],
  shape         = ui.rrect(),
  ontop         = true,
  visible       = false,
  placement     = awful.placement.centered,
  widget        = widget
})

------------------------

local function show_launcher()
  content = launcher
  launcher.switch_callback()
  widget:set_content(launcher)
  opt_launcher:set_active()
  opt_switcher:set_inactive()
  active_opt = LAUNCHER
end

local function show_switcher()
  content = switcher
  switcher.switch_callback()
  widget:set_content(switcher)
  opt_switcher:set_active()
  opt_launcher:set_inactive()
  active_opt = SWITCHER
end

local function prompt()
  awful.prompt.run {
    font                 = beautiful.font_reg_s,
    prompt               = "",
    text                 = "",
    bg_cursor            = beautiful.primary[400],
    textbox              = promptbox,
    keypressed_callback  = function(_, key, input)
      if key == "Escape" or last_key..key == "Alt_Lr" then
        notrofi:close()
      elseif key == "Alt_L" then
        notrofi.mode = "nav"
      elseif key == "Tab" or (notrofi.mode == "nav" and (key == "h" or key == "l")) then
        if active_opt == LAUNCHER then
          show_switcher()
        else
          show_launcher()
        end
      else
        if content.keypressed_callback then
          content.keypressed_callback(_, key, input)
        end
      end
      last_key = key
    end,
    keyreleased_callback = function(_, key, input)
      if notrofi.mode == "nav" then
        if key == "j" then
          notrofi:iter_element(1)
        elseif key == "k" then
          notrofi:iter_element(-1)
        elseif key == "Alt_L" then
          notrofi.mode = ""
        end
        return
      end

      if key == "Down" then
        notrofi:iter_element(1)
        return
      elseif key == "Up" then
        notrofi:iter_element(-1)
        return
      end

      content.keyreleased_callback(_, key, input)
    end,
    exe_callback = function()
      content.exe_callback()
      notrofi:close()
    end
  }
end

------------------------

function notrofi:iter_element(iter_amt)
  if not self.active_element then return end
  self.active_element:emit_signal("mouse::leave")

  local new_idx = math.fmod(self.active_element.index + iter_amt, #content.children)
  if new_idx == 0 then new_idx = #content.children end

  self.active_element = content.children[new_idx]
  if self.active_element then self.active_element:emit_signal("mouse::enter") end
end


notrofi:connect_signal("setstate::open", function()
  notrofi.mode = "nav"
  nrofi.visible = true
  prompt()
end)

notrofi:connect_signal("setstate::close", function()
  awful.keygrabber.stop()
  nrofi.visible = false
end)
