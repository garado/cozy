
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

    -- https://docs.pixe.la/entry/get-pixel
    -- GET - /v1/users/<username>/graphs/<graphID>/<yyyyMMdd>
    -- arguments
    -- habit: pixela graph id
    -- day: 
    local function get_daily_status(graph_id, date, letter)
      local date = "--date " .. date .. " "
      local graph = "--graph-id " .. graph_id .. " "
      local cmd = "pi pixel get " .. date .. graph

      local daily_box = wibox.widget({
        {
          {
            id = "bitch",
            markup = helpers.ui.colorize_text(letter, beautiful.xforeground),
            widget = wibox.widget.textbox,
            align = "center",
            valign = "center",
          },
          forced_height = dpi(30),
          forced_width = dpi(30),
          --bg = beautiful.nord10,
          shape = gears.shape.circle,
          widget = wibox.container.background,
        },
        widget = wibox.container.place,
      })
      
      local script = "exec /home/alexis/.config/awesome/utils/dash/main/habit " .. cmd
      local bg = daily_box.children[1]
      local fg = daily_box:get_children_by_id("bitch")[1]
      awful.spawn.easy_async_with_shell(script, function(stdout)
        local stdout = string.gsub(stdout, "\n", "")
        if stdout == "true" then
          bg.bg = beautiful.nord10
          fg:set_markup_silently(helpers.ui.colorize_text("", beautiful.xforeground))
        elseif stdout == "false" then
          bg.bg = beautiful.nord0
          fg:set_markup_silently(helpers.ui.colorize_text("", beautiful.nord1))
        end
      end)

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
      create_habit_box("Commit", "pomocode"),
      create_habit_box("Journal", "journal"),
      create_habit_box("Exercise", "exercise"),
      create_habit_box("Reading", "exercise"),
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place
  })

  return widget
end

return helpers.ui.create_boxed_widget(widget(), dpi(200), dpi(400), beautiful.dash_widget_bg)
