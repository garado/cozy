
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀
-- █▀█ █▀█ █▄█ █ ░█░ ▄█

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local user_vars = require("user_variables")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local widgets = require("ui.widgets")
local os = os

-- Create list of habits and their statuses for this week
local function habit_overview()
 
  -- Create weekly status for one habit
  local function create_habit_entry(habit, graph_id, frequency)
    local habit_name = wibox.widget({
      markup = helpers.ui.colorize_text(habit, beautiful.xforeground),
      widget = wibox.widget.textbox,
      font = beautiful.font_name .. "12",
      align = "right",
      valign = "center",
    })

    local freq = wibox.widget({
      markup = helpers.ui.colorize_text(frequency, beautiful.nord9),
      widget = wibox.widget.textbox,
      font = beautiful.font_name .. "10",
      align = "right",
      valign = "center",
    })
   
    -- Start constructing the overview
    -- Things will get appended to this box.
    local overview = wibox.widget({
      {
        spacing = dpi(10),
        layout = wibox.layout.flex.horizontal,
      },
      widget = wibox.container.place,
    })

    local function get_daily_status(graph_id, date, letter)
      local cache_dir = gfs.get_cache_dir() .. "pixela"

      -- If file exists, habit was completed and exit code is 0
      -- Else habit wasn't completed; exit code 1
      local file = cache_dir .. "/" .. graph_id .. "/" .. date
      local habitCompleted = gfs.file_readable(file)
      local btn_background, btn_text_color, btn_text
      if habitCompleted then
        btn_text_color = beautiful.xforeground
        btn_background = beautiful.nord10
      else
        btn_text_color = beautiful.xforeground
        btn_background = beautiful.nord0
      end
     
      -- Create a single button
      local daily_box_btn = widgets.button.text.normal({
        text = letter,
        text_normal_bg = btn_text_color,
        normal_bg = btn_background,
        animate_size = false,
        font = beautiful.font,
        size = 12,
        on_release = function()
          if not habitCompleted then
            local cmd = "pi pixel post -g " .. graph_id .. " -d " .. date .. " -q 1"
            awful.spawn(cmd)
          end
        end
      })
     
      -- Create button container
      local daily_box = wibox.widget({
        daily_box_btn,
        forced_height = dpi(35),
        forced_width = dpi(35),
        widget = wibox.container.place,
      })

      return daily_box
    end

    -- Create buttons for a whole week
    local function get_overview(graph_id)
      -- get last 4 days of data
      -- starts from 4 days ago so it appends in the right order
      local current_time = os.time()
      for i = 3, 0, -1 do
        local i_days_ago = current_time - (60 * 60 * 24 * i)
        local day = os.date("%a", i_days_ago)
        
        local date = os.date("%Y%m%d", i_days_ago)
        date = string.gsub(date, "\r\n", "")
        local letter = string.sub(day, 1, 1)
        local box = get_daily_status(graph_id, date, letter)
        overview.children[1]:add(box)
      end
    end

    get_overview(graph_id)

    -- Assemble habit entry
    local habit_entry = wibox.widget({
      {
        {
          habit_name,
          freq,
          forced_width = dpi(125),
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.place,
      },
      overview,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    })

    return habit_entry
  end -- end create_habit_entry

  local header = wibox.widget({
    markup = helpers.ui.colorize_text("Habits", beautiful.dash_header_color),
    font = beautiful.header_font .. "20",
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  -- Habits get appended here 
  local widget = wibox.widget({
    {
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place
  })
 
  -- get habit list from user_variables
  local habit_list = user_vars.habit
  local name = 1
  local id = 2
  local freq = 3
  for _, v in ipairs(habit_list) do
    widget.children[1]:add( create_habit_entry(v[name], v[id], v[freq]) )
  end

  return helpers.ui.create_boxed_widget(widget, dpi(550), dpi(500), beautiful.dash_widget_bg)
end

return habit_overview()
