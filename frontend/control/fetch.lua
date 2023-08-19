
-- █▀▀ █▀▀ ▀█▀ █▀▀ █░█ 
-- █▀░ ██▄ ░█░ █▄▄ █▀█ 

local beautiful = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local gfs   = require("gears.filesystem")
local wibox = require("wibox")

local CFG = gfs.get_configuration_dir()

local fetchlist = wibox.widget({
  spacing = dpi(4),
  layout  = wibox.layout.fixed.vertical,
})

local function create_entry(_title, _value)
  local title = ui.colorize(_title .. " " , beautiful.primary[400])
  local value = ui.colorize(_value, beautiful.neutral[100])

  return wibox.widget({
    ui.textbox({
      text  = title,
      width = dpi(40),
      align = "right",
    }),
    ui.textbox({
      text  = value,
    }),
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
  })
end

-- Extract data from script stdout
local function extract_entry(stdout, name)
  local val = stdout:match(name .. ":(.-)\n")
  if not val then return end
  val = string.gsub(val, val .. ":", "")
  val = string.lower(val)
  local entry = create_entry(name, val)
  fetchlist:add(entry)
end

local script = CFG .. "utils/scripts/ctrlfetch"
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
