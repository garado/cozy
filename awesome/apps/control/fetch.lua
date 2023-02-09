
-- █▀▀ █▀▀ ▀█▀ █▀▀ █░█ 
-- █▀░ ██▄ ░█░ █▄▄ █▀█ 

local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local awful = require("awful")
local ui    = require("helpers.ui")
local gfs   = require("gears.filesystem")
local wibox = require("wibox")

local CFG = gfs.get_configuration_dir()

local fetchlist = wibox.widget({
  spacing = dpi(2),
  layout  = wibox.layout.fixed.vertical,
})

local function create_entry(_title, _value)
  local title = ui.colorize(_title .. " " , beautiful.primary_0)
  local value = ui.colorize(_value, beautiful.fg_0)

  return wibox.widget({
    {
      forced_width = dpi(100),
      font   = beautiful.font_reg_s,
      markup = title,
      align  = "right",
      valign = "top",
      widget = wibox.widget.textbox,
    },
    {
      forced_width = dpi(100),
      font   = beautiful.font_reg_s,
      markup = value,
      align  = "left",
      valign = "top",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(5),
    layout  = wibox.layout.flex.horizontal,
  })
end

-- Extract data from script stdout
local function extract_entry(out, name)
  local val = out:match(name .. ":(.-)\n")
  if not val then return end
  val = string.gsub(val, val .. ":", "")
  val = string.lower(val)
  local entry = create_entry(name, val)
  fetchlist:add(entry)
end

local script = CFG .. "utils/dash/fetch"
awful.spawn.easy_async_with_shell(script, function(stdout)
  extract_entry(stdout, "os")
  extract_entry(stdout, "host")
  extract_entry(stdout, "wm")
  extract_entry(stdout, "pkg")
end)

return wibox.widget({
  fetchlist,
  widget = wibox.container.place,
})
