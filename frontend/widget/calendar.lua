
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- UI inspiration comes from the excellent Timepage app for iOS

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local gears = require("gears")
local gtable = require("gears.table")

local calendar = {}

--- @function gen_daylabel
-- @brief Generates a single week label (SMTWTFS).
-- @param i A number 1-7 representing the day of the week.
local function gen_daylabel(i)
  local weekmap = { "S", "M", "T", "W", "T", "F", "S" }
  return ui.textbox({
    text  = weekmap[i],
    color = beautiful.neutral[200],
    font  = beautiful.font_light_xs,
    width = dpi(40),
    height = dpi(40),
    align = "center",
  })
end

--- @function gen_day
-- @brief Generate a day entry for the calendar.
local function gen_day(i)
  local content = wibox.widget({
    ui.textbox({
      text  = i,
      align = "center",
    }),
    forced_height = dpi(20),
    forced_width  = dpi(20),
    shape  = gears.shape.circle,
    bg     = beautiful.neutral[700],
    widget = wibox.container.background,
  })

  -- The base content gets wrapped into 3 different circular borders.
  -- 1st (innermost) is highlight
  -- 2nd is just filler stuff (noninteractive)
  -- 3rd (outermost) is select

  local highlight = ui.cborder(content)

  local filler    = ui.cborder(highlight)
  filler:update_border(beautiful.neutral[700])

  local day       = ui.cborder(filler)

  function day:update_fg(color)
    content.widget:update_color(color)
  end

  function day:update_bg(color)
    content.bg = color or beautiful.neutral[700]
  end

  function day:update_highlight(color)
    -- If no color provided, it will clear the highlight
    highlight:update_border(color)
  end

  function day:update_select(isSelected)
    local sel_color = isSelected and beautiful.primary[400] or beautiful.neutral[700]
    day:update_border(sel_color)
  end

  -- User interaction
  day:connect_signal("button::press", function(self)
    self:update_select(true)
  end)

  day:connect_signal("mouse::enter", function(self)
    self:update_highlight(beautiful.fg)
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
  }
  gtable.crush(args, userargs or {})

  local month_label = ui.textbox({
    text = "May 2023",
    font = beautiful.font_reg_m,
    align = "center",
  })

  local daygrid = wibox.widget({
    forced_num_cols = 7,
    horizontal_spacing = dpi(5),
    vertical_spacing = dpi(4),
    layout = wibox.layout.grid,
  })

  for i = 1, 7 do
    daygrid:add(gen_daylabel(i))
  end

  -- If necessary, backfill daygrid with days from the previous month
  local first_wday = os.date("%w", now_ts)
  local filler_ts = now_ts - (24 * 60 * 60)
  for _ = 1, first_wday do
    daygrid:add(ui.textbox({
      text  = os.date("%d", filler_ts),
      align = "center",
      color = beautiful.neutral[400],
    }))
    filler_ts = filler_ts - (24 * 60 * 60)
  end

  for i = 1, 31 do
    local day = gen_day(i)
    if i == tonumber(os.date("%d")) then
      day:update_fg(beautiful.primary[400])
      day:update_bg(beautiful.fg)
      day:update_highlight(beautiful.primary[400])
    end
    daygrid:add(day)
  end

  -- Fill the rest of the calendar with days from the next month
  local filler_date = 1
  while #daygrid.children % 7 ~= 0 do
    daygrid:add(ui.textbox({
      text  = filler_date,
      align = "center",
      color = beautiful.neutral[400],
    }))
    filler_date = filler_date + 1
  end

  calendar = wibox.widget({
    month_label,
    daygrid,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  })

  return calendar
end

return setmetatable(calendar, { __call = function(_, ...) return worker(...) end })
