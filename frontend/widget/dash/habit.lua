
-- █░█ ▄▀█ █▄▄ █ ▀█▀ 
-- █▀█ █▀█ █▄█ █ ░█░ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local gtable = require("gears.table")

local habit = {}

--- @function gen_day
-- Generates an interactive checkbox-style habit button.
local function gen_day(text, func)
  local day = wibox.widget({
    {
      ui.textbox({
        text = text,
        font = beautiful.font_reg_xs,
      }),
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    bg     = beautiful.primary[400],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
  })

  day.ticked_props = {
    bg    = beautiful.primary[400],
    bg_mo = beautiful.primary[500],
    fg    = beautiful.fg,
    fg_mo = beautiful.fg,
  }

  day.unticked_props = {
    bg    = beautiful.neutral[500],
    bg_mo = beautiful.neutral[600],
    fg    = beautiful.neutral[300],
    fg_mo = beautiful.neutral[300],
  }

  day.ticked = false
  day.props  = day.unticked_props
  day.func   = func

  function day:update()
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
    self.props  = self.ticked and self.ticked_props or self.unticked_props
    self:update()
    if self.func then
      self:func(self.ticked)
    end
  end)

  day:update()
  return day
end

local function worker(userargs)
  local args = {
    title     = "Title",
    frequency = "Frequency",
  }
  gtable.crush(args, userargs)

  habit = wibox.widget({
    { -- Header
      ui.textbox({
        text = args.title,
        font = beautiful.font_bold_s,
      }),
      nil,
      ui.textbox({
        text  = args.frequency,
        color = beautiful.neutral[400],
      }),
      layout = wibox.layout.align.horizontal,
    },
    { -- Day icon container
      spacing = dpi(12),
      layout  = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  })

  --- @method init
  -- @brief Add day icons
  function habit:init()
    for i = 1, 7 do
      self.children[2]:add(gen_day(i))
    end
  end

  habit:init()
  return wibox.widget({
    {
      habit,
      top     = dpi(13),
      bottom  = dpi(13),
      left    = dpi(30),
      right   = dpi(30),
      widget  = wibox.container.margin,
    },
    bg     = beautiful.neutral[800],
    shape  = ui.rrect(),
    widget = wibox.container.background,
  })
end

return setmetatable(habit, { __call = function(_, ...) return worker(...) end })
