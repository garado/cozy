
-- █▀▀ █▀▀ ▀█▀ █▀▀ █░█ 
-- █▀░ ██▄ ░█░ █▄▄ █▀█ 

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gfs = require("gears.filesystem")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Base widget to append to
local widget = wibox.widget({
  {
    spacing = dpi(2),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

-- Make output look pretty
local function create_entry(title, value)
  -- Make things pretty
  local colorized_title = helpers.ui.colorize_text(title .. " " , beautiful.ctrl_fetch_accent)
  local colorized_value = helpers.ui.colorize_text(value, beautiful.ctrl_fetch_value)
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
  if not val then return end
  val = string.gsub(val, val .. ":", "")
  val = string.lower(val)
  create_entry(name, val)
end

local function create_fetch()
  local cfg = gfs.get_configuration_dir()
  local script = cfg .. "utils/dash/fetch"
  awful.spawn.easy_async_with_shell(script, function(stdout)
    extract_entry(stdout, "os")
    extract_entry(stdout, "host")
    extract_entry(stdout, "wm")
    extract_entry(stdout, "pkg")
  end)
end

create_fetch()

return widget
