
-- █▀▄ ▄▀█ █▀ █░█ ▀   █░█ ▄▀█ █▄▄ █ ▀█▀ █▀
-- █▄▀ █▀█ ▄█ █▀█ ▄   █▀█ █▀█ █▄█ █ ░█░ ▄█

-- Integrated with Pixela!

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local os = os

local function widget()
  local random_color = beautiful.random_accent_color()

  local function create_habit_box(habit)
    local habit_name = wibox.widget({
      markup = helpers.ui.colorize_text(habit, beautiful.xforeground),
      widget = wibox.widget.textbox,
      font = beautiful.font .. "15",
      align = "left",
      valign = "center",
    })

    local frequency = wibox.widget({
      markup = helpers.ui.colorize_text("daily", beautiful.xforeground),
      widget = wibox.widget.textbox,
      align = "right",
      valign = "center",
    })
   
    --------------
    -- OVERVIEW --
    --------------
    local overview = wibox.widget({
      {
        spacing = dpi(10),
        layout = wibox.layout.flex.horizontal,
      },
      widget = wibox.container.place,
    })

    local function get_daily_status(habit, day)
      local daily_box = wibox.widget({
        {
          {
            markup = helpers.ui.colorize_text(day, beautiful.xforeground),
            widget = wibox.widget.textbox,
            font = beautiful.header_font .. "11",
            align = "center",
            valign = "center",
          },
          forced_height = dpi(30),
          forced_width = dpi(30),
          bg = random_color,
          shape = gears.shape.circle,
          widget = wibox.container.background,
        },
        widget = wibox.container.place,
      })
      return daily_box
    end
    
    local function get_overview()
      -- get last 5 days of data
      local current_day = os.date("%a")
      for i = 1, 5, 1 do
        local 
        letter = string.sub(current_day, 1, 1)
        local box = get_daily_status("empty", letter)
        overview.children[1]:add(box)
      end
    end

    get_overview()

    local widget = wibox.widget({
      {
        {
          {
            habit_name,
            nil,
            frequency,
            layout = wibox.layout.align.horizontal,
          },
          overview,
          layout = wibox.layout.fixed.vertical,
        },
        margins = {
          top = dpi(5),
          bottom = dpi(5),
          left = dpi(15),
          right = dpi(15),
        },
        widget = wibox.container.margin,
      },
      forced_width = dpi(300),
      bg = beautiful.nord1,
      shape = helpers.ui.rrect(dpi(5)),
      widget = wibox.container.background,
    })

    return widget
  end

  local header = wibox.widget({
    markup = helpers.ui.colorize_text("Habits", beautiful.dash_header_color),
    font = beautiful.header_font .. "20",
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  local widget = wibox.widget({
    {
      header,
      create_habit_box("Commit"),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place
  })

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(200), dpi(200), beautiful.dash_widget_bg)
