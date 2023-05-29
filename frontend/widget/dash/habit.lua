
-- █░█ ▄▀█ █▄▄ █ ▀█▀ 
-- █▀█ █▀█ █▄█ █ ░█░ 

-- Habit checkboxes for the last 5 days. Powered by Pixela.
-- Goes on the main tab of the dashboard.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local pixela = require("backend.system.pixela")
local gtable = require("gears.table")

local SECONDS_IN_DAY = 24 * 60 * 60

local habit = {}

--- @function gen_day
-- @brief Generates a single interactive checkbox-style habit button.
--        The habit widget is a group of these smaller day-widgets.
-- @param id    Pixela graph ID for habit
-- @param ts    os.time timestamp for the day of the habit entry (awful wording but you get it)
-- @param func  Function to call when the button is pressed. 
--              Function is passed the new checkbox state as a parameter.
local function gen_day(id, ts, func)
  local day = wibox.widget({
    {
      ui.textbox({
        text = tostring(os.date("%a", ts)):sub(1, 1),
        font = beautiful.font_reg_xs,
        align = "center",
      }),
      margins = dpi(5),
      widget  = wibox.container.margin,
    },
    forced_width = dpi(30),
    bg     = beautiful.primary[400],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
  })

  day.ticked_props = {
    bg    = beautiful.primary[500],
    bg_mo = beautiful.primary[400],
    fg    = beautiful.fg,
    fg_mo = beautiful.fg,
  }

  day.unticked_props = {
    bg    = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
    fg    = beautiful.neutral[300],
    fg_mo = beautiful.neutral[300],
  }

  day.ts = ts
  day.id = id
  day.func = func
  -- day.ticked = false
  day.ticked = pixela:read_habit_data(id, ts)

  function day:update()
    self.props = (self.ticked and self.ticked_props) or self.unticked_props
    self.bg = self.props.bg
    self.children[1].widget:update_color(self.props.fg)
  end

  day:connect_signal("mouse::enter", function(self)
    self.bg = self.props.bg_mo
    self.children[1].widget:update_color(self.props.fg_mo)
  end)

  day:connect_signal("mouse::leave", function(self)
    self.bg = self.props.bg
    self.children[1].widget:update_color(self.props.fg)
  end)

  day:connect_signal("button::press", function(self)
    self.ticked = not self.ticked
    self:update()
    if self.func then self:func(self.ticked) end
  end)

  day:update()
  return day
end

local function worker(userargs)
  local args = {
    id        = nil, -- Pixela graph ID (required)
    title     = "Title", -- Display name
    frequency = "Frequency",
  }
  gtable.crush(args, userargs or {})

  habit = wibox.widget({
    { -- Header
      ui.textbox({
        text = args.title,
        font = beautiful.font_bold_s,
        align = "right",
        width = dpi(65),
      }),
      ui.textbox({
        text  = args.frequency,
        color = beautiful.neutral[400],
        align = "right",
      }),
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical,
    },
    { -- Day icon container
      spacing = dpi(12),
      layout  = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  })

  habit.id = args.id

  local ts = os.time()
  for _ = 1, 5 do
    local day = gen_day(args.id, ts, function(day, isChecked)
      pixela:update_habit(day.id, day.ts, isChecked)
    end)
    habit.children[2]:insert(1, day)
    ts = ts - SECONDS_IN_DAY
  end

  return wibox.widget({
    habit,
    top     = dpi(8),
    bottom  = dpi(8),
    left    = dpi(30),
    right   = dpi(30),
    widget  = wibox.container.margin,
  })
end

return setmetatable(habit, { __call = function(_, ...) return worker(...) end })
