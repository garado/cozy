
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀ 
-- █▀█ █▀█ █▄█ █ ░█░ ▄█ 

-- Habit tracker with Pixela backend.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local conf  = require("cozyconf")
local dash  = require("backend.cozy.dash")
local keynav = require("modules.keynav")
local pixela = require("backend.system.pixela")

if not pixela then
  local default = ui.textbox({
    text = "Habit tracking not configured - please see the wiki.",
    align = "center",
    color = beautiful.neutral[500],
  })

  return ui.dashbox_v2(wibox.container.place(default))
end

local habit = require(... .. ".habit")

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

function labels:update()
  self:reset()
  local ts = os.time()
  for _ = 1, 8 do
    self:insert(1, ui.textbox({
      text  = os.date("%d", ts),
      width = dpi(20),
      align = "center",
      font  = beautiful.font_reg_xs,
    }))
    ts = ts - SECONDS_PER_DAY
  end
end
labels:update()

local function refresh()
  pixela:get_all_graph_pixels()
  labels:update()
end

dash:connect_signal("date::changed", refresh)

local widget = wibox.widget({
  {
    ui.hpad(70), -- Align labels with checkboxes
    labels,
    layout = wibox.layout.fixed.horizontal,
  },
  wibox.container.place(habits),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

local tmp = ui.rrborder( ui.dashbox_v2(widget) )

tmp.keynav = keynav.area({
  name = "nav_habits",
  keys = {
    ["r"] = refresh
  },
  widget = tmp,
})

return tmp
