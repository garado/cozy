
-- █▀▀ █▀▀ ▀█▀ █▀▀ █░█
-- █▀░ ██▄ ░█░ █▄▄ █▀█

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

-- Base widget
local widget = wibox.widget({
  {
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

-- Aesthetics
local function create_entry(title, value)
  -- Make things pretty
  local colorized_title = helpers.ui.colorize_text(title .. " " , beautiful.fetch_title)
  local colorized_value = helpers.ui.colorize_text(value, beautiful.fetch_bg)
  local entry = wibox.widget({
    {
      markup = colorized_title,
      widget = wibox.widget.textbox,
      forced_width = dpi(100),
      align = "right",
      valign = "top",
    },
    {
      markup = colorized_value,
      widget = wibox.widget.textbox,
      forced_width = dpi(100),
      align = "left",
      valign = "top",
    },
    layout = wibox.layout.flex.horizontal,
  })

  -- Insert into widget
  widget.children[1]:add(entry)
end

-- extract data from script stdout
local function extract_entry(out, name)
  local val = out:match(name .. ":(.-)\n")
  val = string.gsub(val, val .. ":", "")
  val = string.lower(val)
  create_entry(name, val)
end

local function fuck()
  -- ugh fix later
  local script="exec /home/alexis/.config/awesome/utils/dash/main/fetch"
  awful.spawn.easy_async_with_shell(script, function(stdout)
    extract_entry(stdout, "os")
    extract_entry(stdout, "wm")
    extract_entry(stdout, "pkg")
    extract_entry(stdout, "up")
    extract_entry(stdout, "shell")
  end)
end

fuck()

return helpers.ui.create_boxed_widget(widget, dpi(220), dpi(160), beautiful.dash_widget_bg) 
