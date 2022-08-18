
-- █▀▄ ▄▀█ █▀ █░█ ▀   █░█ ▄▀█ █▄▄ █ ▀█▀ █▀
-- █▄▀ █▀█ ▄█ █▀█ ▄   █▀█ █▀█ █▄█ █ ░█░ ▄█

-- Integrated with Pixela!

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local os = os

local function widget()
  local function create_habit_box(habit, graph_id)
    local habit_name = wibox.widget({
      markup = helpers.ui.colorize_text(habit, beautiful.xforeground),
      widget = wibox.widget.textbox,
      font = beautiful.font .. "15",
      align = "left",
      valign = "center",
    })

    local frequency = wibox.widget({
      markup = helpers.ui.colorize_text("daily", beautiful.nord9),
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


    local function get_daily_status(graph_id, date, letter)
      local cache_dir = "/home/alexis/.cache/awesome/pixela"
      local daily_box = wibox.widget({
        {
          {
            id = "textbox",
            markup = helpers.ui.colorize_text(letter, beautiful.xforeground),
            widget = wibox.widget.textbox,
            align = "center",
            valign = "center",
          },
          forced_height = dpi(30),
          forced_width = dpi(30),
          shape = gears.shape.circle,
          widget = wibox.container.background,
        },
        widget = wibox.container.place,
      })
      
      -- If file exists, habit was completed and exit code is 0
      -- Else habit wasn't completed; exit code 1
      local bg = daily_box.children[1]
      local fg = daily_box:get_children_by_id("textbox")[1]
      
      local file = cache_dir .. "/" .. graph_id .. "/" .. date
      if gfs.file_readable(file) then
        bg.bg = beautiful.nord10
        fg:set_markup_silently(helpers.ui.colorize_text("", beautiful.xforeground))
      else
        bg.bg = beautiful.nord0
        fg:set_markup_silently(helpers.ui.colorize_text("", beautiful.nord1))
      end

      return daily_box
    end

    local function get_overview(graph_id)
      -- get last 7 days of data
      -- starts from 7 days ago so it appends in the right order
      local current_time = os.time()
      for i = 6, 0, -1 do
        -- i days ago
        local ago = current_time - (60 * 60 * 24 * i)
        local day = os.date("%a", ago)
        
        local date = os.date("%Y%m%d", ago)
        date = string.gsub(date, "\r\n", "")
        local letter = string.sub(day, 1, 1)
        local box = get_daily_status(graph_id, date, letter)
        overview.children[1]:add(box)
      end
    end

    get_overview(graph_id)

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
          spacing = dpi(10),
          layout = wibox.layout.fixed.vertical,
        },
        margins = {
          top = dpi(10),
          bottom = dpi(10),
          left = dpi(15),
          right = dpi(15),
        },
        widget = wibox.container.margin,
      },
      forced_width = dpi(330),
      bg = beautiful.nord1,
      shape = helpers.ui.rrect(dpi(beautiful.border_radius)),
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
      --header,
      create_habit_box("Code", "pomocode"),
      create_habit_box("Journal", "journal"),
      create_habit_box("Reading", "reading"),
      create_habit_box("Ledger", "ledger"),
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place
  })

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(200), dpi(400), beautiful.dash_widget_bg)
