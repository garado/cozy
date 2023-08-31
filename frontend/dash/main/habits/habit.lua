
-- █░█ ▄▀█ █▄▄ █ ▀█▀    █░█░█ █ █▀▄ █▀▀ █▀▀ ▀█▀
-- █▀█ █▀█ █▄█ █ ░█░    ▀▄▀▄▀ █ █▄▀ █▄█ ██▄ ░█░

-- Creates tracker for one individual habit.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local pixela = require("backend.system.pixela")
local strutil = require("utils.string")

local SECONDS_PER_DAY = 24 * 60 * 60

local habit = {}

--- @function gen_day
-- @brief Generates a checkbox indicating habit completion for a certain day.
local function gen_day(id, ts)
  local day = wibox.widget({
    {
      ui.textbox({
        text  = "",
        font  = beautiful.font_reg_xs,
        align = "center",
      }),
      margins = dpi(0),
      widget  = wibox.container.margin,
    },
    forced_width  = dpi(20),
    forced_height = dpi(20),
    bg     = beautiful.primary[400],
    shape  = ui.rrect(dpi(2)),
    widget = wibox.container.background,
  })

  day.ticked_props = {
    bg    = beautiful.primary[500],
    bg_mo = beautiful.primary[400],
    fg    = beautiful.fg,
    fg_mo = beautiful.fg,
    text  = "󰄬",
  }

  day.unticked_props = {
    bg    = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
    fg    = beautiful.neutral[300],
    fg_mo = beautiful.neutral[300],
    text  = "",
  }

  day.id = id
  day.ts = ts
  day.ticked = false

  function day:update()
    self.props = (self.ticked and self.ticked_props) or self.unticked_props
    self.bg = self.props.bg
    self.children[1].widget:update_color(self.props.fg)
    self.children[1].widget:update_text(self.props.text)
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
    pixela:put_habit_status(id, ts, self.ticked)
  end)

  day:update()
  return day
end

local function worker(id)
  local boxes = wibox.widget({
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal,
  })

  local ts = os.time()
  for _ = 1, 8 do
    boxes:insert(1, gen_day(id, ts))
    ts = ts - SECONDS_PER_DAY
  end

  pixela:connect_signal("ready::"..id, function(_, stdout)
    ts = os.time()
    for i = #boxes.children, 1, -1 do
      local date = os.date(pixela.date_format, ts)
      boxes.children[i].ticked = strutil.contains(stdout, date)
      boxes.children[i]:update()
      ts = ts - SECONDS_PER_DAY
    end
  end)

  pixela:read_graph_pixels(id)

  return wibox.widget({
    ui.textbox({
      text  = id,
      width = dpi(60),
      align = "right",
    }),
    boxes,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
  })
end

return setmetatable(habit, { __call = function(_, ...) return worker(...) end })
