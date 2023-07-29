
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

local wibox = require("wibox")
local ui    = require("utils.ui")
local dpi   = require("utils.ui").dpi
local dash  = require("backend.cozy.dash")
local beautiful = require("beautiful")
local keynav    = require("modules.keynav")
local cozyconf  = require("cozyconf")

local events = require(... .. ".events")
local tasks  = require(... .. ".duedates")
local habits = require(... .. ".habits")
local time   = require(... .. ".time")

local nav_main = keynav.area({
  name  = "nav_main",
  autofocus = false,
  items = {
    time.keynav,
    habits.keynav,
  }
})

local main_header = wibox.widget({
  ui.textbox({
    text  = "Good afternoon, Alexis",
    align = "left",
    font  = beautiful.font_reg_xl,
  }),
  nil,
  ui.textbox({
    text  = "3:45PM",
    align = "right",
    font  = beautiful.font_reg_l,
  }),
  layout = wibox.layout.align.horizontal,
})

dash:connect_signal("setstate::open", function(_)
  local gmkup
  local name = cozyconf.name
  local hour = tonumber(os.date("%H"))
  if hour < 6 then
    gmkup = ui.colorize("Having a late night, ", beautiful.fg) ..
           ui.colorize(name .. "?", beautiful.primary[500])
  elseif hour < 12 then
    gmkup = ui.colorize("Good morning, ", beautiful.fg) ..
           ui.colorize(name, beautiful.primary[500])
  elseif hour < 18 then
    gmkup = ui.colorize("Good afternoon, ", beautiful.fg) ..
           ui.colorize(name, beautiful.primary[500])
  else
    gmkup = ui.colorize("Good evening, ", beautiful.fg) ..
           ui.colorize(name, beautiful.primary[500])
  end
  main_header.children[1].markup = gmkup

  -- Strip leading 0 from hour and day of month.
  local timetxt = tonumber(os.date("%I")) .. ':' .. os.date("%M")
  local datetxt = os.date("%A %B ") .. tonumber(os.date("%d"))
  local tmkup = ui.colorize(datetxt, beautiful.fg) .. ' ' ..
                ui.colorize(timetxt, beautiful.primary[400])
  main_header.children[2].markup = tmkup
end)

local content = wibox.widget({
  {
    events,
    tasks,
    spacing = dpi(35),
    layout = wibox.layout.fixed.vertical,
  },
  nil,
  {
    time,
    habits,
    spacing = dpi(15),
    layout  = wibox.layout.fixed.vertical,
  },
  layout = wibox.layout.align.horizontal,
})

local container = wibox.widget({
  main_header,
  {
    content,
    margins = dpi(15),
    widget = wibox.container.margin,
  },
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return container, nav_main
end
