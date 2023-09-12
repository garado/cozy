
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- UI inspiration comes from the excellent Timepage app for iOS

local ui  = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local gears = require("gears")
local gtable = require("gears.table")
local keynav = require("modules.keynav")
local beautiful = require("beautiful")
local os = os

local calendar = {}

local SECONDS_IN_DAY = 24 * 60 * 60
local WEEKMAP = { "S", "M", "T", "W", "T", "F", "S" }

--- @function gen_filler_day
local function gen_filler_day(ts)
  local day = wibox.widget({
    ui.textbox({
      text  = os.date("%d", ts),
      align = "center",
      color = beautiful.neutral[400],
      font  = beautiful.font_reg_xs,
    }),
    forced_height = dpi(20),
    forced_width  = dpi(20),
    shape  = gears.shape.circle,
    bg     = beautiful.neutral[800],
    widget = wibox.container.background,
  })

  day:connect_signal("button::press", function(self)
  end)

  day:connect_signal("mouse::enter", function(self)
    self.bg = beautiful.neutral[600]
  end)

  day:connect_signal("mouse::leave", function(self)
    self.bg = beautiful.neutral[700]
  end)

  return day
end

--- @function gen_day
-- @brief Generate a day entry for the calendar.
local function gen_day(ts, func)
  local content = wibox.widget({
    ui.textbox({
      text  = os.date("%d", ts),
      align = "center",
    }),
    forced_height = dpi(20),
    forced_width  = dpi(20),
    shape  = gears.shape.circle,
    bg     = beautiful.neutral[800],
    widget = wibox.container.background,
  })

  -- The base content gets wrapped into 3 different circular borders.
  -- 1st (innermost) is highlight
  -- 2nd is just filler stuff (noninteractive)
  -- 3rd (outermost) is select

  local highlight = ui.cborder(content)

  local filler = ui.cborder(highlight)
  filler:update_border(beautiful.neutral[800])

  local day       = ui.cborder(filler)

  function day:update_fg(color)
    content.widget:update_color(color)
  end

  function day:update_bg(color)
    content.bg = color or beautiful.neutral[800]
  end

  function day:update_highlight(color)
    -- If no color provided, it will clear the highlight
    highlight:update_border(color)
  end

  function day:update_select(isSelected)
    local sel_color = isSelected and beautiful.primary[400] or beautiful.neutral[800]
    day:update_border(sel_color)
  end

  -- TODO: User interaction
  day:connect_signal("button::press", function(self)
    self:update_select(true)
    if func then func(ts) end
  end)

  day:connect_signal("mouse::enter", function(self)
    self:update_highlight(beautiful.neutral[100])
  end)

  day:connect_signal("mouse::leave", function(self)
    self:update_highlight()
  end)

  return day
end

--- @function worker
-- @brief Instantiates a calendar widget.
local function worker(userargs)
  local now_dt = os.date("*t")
  local now_ts = os.time({
    day = 1,
    month = now_dt.month,
    year = now_dt.year,
  })

  local args = {
    -- Date ts representing the 1st day of the month to display
    ts = now_ts,

    -- Function to execute when day is pressed
    -- The timestamp(?) gets passed as param to this function
    on_day_press = nil,
  }
  gtable.crush(args, userargs or {})

  local area = keynav.area({
    name = "nav_calwidget",
    is_grid = true,
    num_cols = 7,
    keys = {
      ["H"] = function()
        calendar:change_month(calendar.ts - SECONDS_IN_DAY)
      end,
      ["L"] = function()
        calendar:change_month(calendar.ts + (SECONDS_IN_DAY * 32))
      end,
      ["t"] = function()
        calendar:change_month()
      end,
    }
  })

  local month_label = ui.textbox({
    text = os.date("%B %Y"),
    font = beautiful.font_reg_m,
    align = "center",
  })

  local daygrid = wibox.widget({
    forced_num_cols = 7,
    horizontal_spacing = dpi(5),
    vertical_spacing = dpi(4),
    layout = wibox.layout.grid,
  })

  calendar = wibox.widget({
    month_label,
    daygrid,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
    ---
    area = area
  })

  --- @method change_month
  -- @param ts  Timestamp occurring any time within the month to draw.
  function calendar:change_month(ts)
    ts = ts or now_ts

    -- Ensure ts points to the first day of the month
    local datetable = os.date("*t", ts)
    ts = os.time({
      day   = 1,
      month = datetable.month,
      year  = datetable.year,
    })
    self.ts = ts

    daygrid:reset()
    area:clear()
    month_label:update_text(os.date("%B %Y", ts))

    for i = 1, 7 do
      local daylabel = ui.textbox({
        text  = WEEKMAP[i],
        color = beautiful.neutral[200],
        font  = beautiful.font_reg_xs,
        align = "center",
        width = dpi(40),
        height = dpi(40),
      })
      daygrid:add(daylabel)
    end

    -- If necessary, backfill grid with days from the previous month
    local first_wday = os.date("%w", ts)
    ts = ts - (SECONDS_IN_DAY * first_wday)
    for _ = 1, first_wday do
      local filler = gen_filler_day(ts)
      daygrid:add(filler)
      area:append(filler)
      ts = ts + SECONDS_IN_DAY
    end

    local month = os.date("%b", ts)

    -- Fill with days for the current month
    while os.date("%b", ts) == month do
      local day = gen_day(ts, args.on_day_press)

      -- If it's today, get fancy coloring
      if os.date("%d", ts) == os.date("%d") then
        day:update_fg(beautiful.primary[400])
        day:update_bg(beautiful.neutral[100])
        day:update_highlight(beautiful.primary[400])
      end

      daygrid:add(day)
      area:append(day)

      ts = ts + SECONDS_IN_DAY
    end

    -- Fill the rest of the calendar with days from the next month
    while #daygrid.children % 7 ~= 0 do
      local filler = gen_filler_day(ts)
      daygrid:add(filler)
      area:append(filler)
      ts = ts + SECONDS_IN_DAY
    end
  end

  calendar:change_month()
  return calendar
end

return setmetatable(calendar, { __call = function(_, ...) return worker(...) end })
