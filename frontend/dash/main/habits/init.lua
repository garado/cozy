
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀ 
-- █▀█ █▀█ █▄█ █ ░█░ ▄█ 

-- Habit tracker with Pixela backend.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local habit = require(... .. ".habit")
local conf  = require("cozyconf")
local dash  = require("backend.cozy.dash")
local pixela = require("backend.system.pixela")
local keynav = require("modules.keynav")

local SECONDS_PER_DAY = 24 * 60 * 60

local habits = wibox.widget({
  spacing = dpi(8),
  layout  = wibox.layout.fixed.vertical,
})

for i = 1, #conf.habits do
  habits:add(habit(conf.habits[i]))
end

local labels = wibox.widget({
  spacing = dpi(8),
  layout = wibox.layout.fixed.horizontal,
})

local function refresh()
  pixela:get_all_graph_pixels()

  -- Update labels
  local ts = os.time()
  for _ = 1, 7 do
    labels:insert(1, ui.textbox({
      text  = os.date("%d", ts),
      width = dpi(20),
      align = "center",
      font  = beautiful.font_reg_xs,
    }))
    ts = ts - SECONDS_PER_DAY
  end
end

dash:connect_signal("date::changed", refresh)

local widget = wibox.widget({
  {
    {
      {
        ui.hpad(dpi(90)),
        labels,
        layout = wibox.layout.fixed.horizontal,
      },
      ui.place(habits),
      layout = wibox.layout.fixed.vertical,
    },
    top    = dpi(20),
    bottom = dpi(20),
    widget = wibox.container.margin,
  },
  bg     = beautiful.neutral[800],
  shape  = ui.rrect(),
  widget = wibox.container.background,
})

local tmp = ui.rrborder(widget)

tmp.keynav = keynav.area({
  name = "nav_habits",
  keys = {
    ["r"] = refresh
  },
  widget = tmp,
})

return tmp
