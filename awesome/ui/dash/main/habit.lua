
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
local json = require("modules.json")

local os = os
local string = string

-- habits get appended here later
local habit_list = user_vars.habit
local habit_widget = wibox.widget({
  {
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

-- update cache for just one graph 
local function update_cache(graph_id)
  local dir = gfs.get_configuration_dir() .. "utils/dash/habits/"
  local cmd = dir .. "cache_habits today 5 " .. graph_id
  awful.spawn(cmd)
end

-- populates habit_widget with habits
local function create_habit_ui()
  -- creates just one habit
  local function create_habit_ui_entry(habit_name, graph_id, frequency)
    local habit_name = wibox.widget({
      markup = helpers.ui.colorize_text(habit_name, beautiful.xforeground),
      font = beautiful.font_name .. "12",
      align = "right",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local freq = wibox.widget({
      markup = helpers.ui.colorize_text(frequency, beautiful.nord9),
      font = beautiful.font_name .. "10",
      align = "right",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    -- skeleton for habit_entry
    local habit_entry = wibox.widget({
      id = graph_id,
      {
        { 
          habit_name,
          freq,
          forced_width = dpi(125),
          layout = wibox.layout.fixed.vertical,
        },
        widget = wibox.container.place,
      },
      {
        id = "days",
        spacing = dpi(10),
        layout = wibox.layout.flex.horizontal,
      },
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    })

    local days = habit_entry:get_children_by_id("days")[1]

    -- grab graph data from cache
    local file = gfs.get_cache_dir() .. "pixela/" .. graph_id
    local cmd = "cat " .. file
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      -- check cache for last 4 days status
      for i = 3, 0, -1 do
        local current_time = os.time()
        local i_days_ago = current_time - (60 * 60 * 24 * i)
        local date = os.date("%Y%m%d", i_days_ago)

        local btn_bg, qty
        if string.find(stdout, date) ~= nil then
          -- habit was completed 
          btn_bg = beautiful.nord10
          qty = 0 -- pressing button will set habit to this value
        else
          btn_bg = beautiful.nord0
          qty = 1
        end

        -- assemble ui
        -- the buttons aren't entirely functional
        -- for now only going false->true works,
        -- and the button colors only update on restart
        local day_initial = os.date("%a", i_days_ago)
        day_initial = string.sub(day_initial, 1, 1)
        local day
        day = widgets.button.text.normal({
          text = day_initial,
          text_normal_bg = beautiful.xforeground,
          normal_bg = btn_bg,
          animate_size = false,
          font = beautiful.font,
          size = 12,
          on_release = function()
            -- update in pixela
            local pi_cmd = "pi pixel update -g " .. graph_id .. " -d " .. date .. " -q " .. qty
            awful.spawn.easy_async_with_shell(pi_cmd, function(stdout)
              if string.find(stdout, "Success.") ~= nil then
                naughty.notification {
                  app_name = "System notification",
                  title = "Habit tracker",
                  message = "Pixela update successfully",
                }
              else
                naughty.notification {
                  app_name = "System notification",
                  title = "Habit tracker",
                  message = "Pixela update failed",
                  timeout = 0,
                }
              end
              update_cache(graph_id)
            end)
          end,
        })

        days:add(day)
      end -- end for
    end) -- end async

    return habit_entry
  end -- create_habit_entry()

  for i = 1, #habit_list do
    local name = habit_list[i][1]
    local id = habit_list[i][2]
    local freq = habit_list[i][3]
    local entry = create_habit_ui_entry(name, id, freq)
    habit_widget.children[1]:add(entry)
  end
end -- create_habit_ui()

create_habit_ui()

return helpers.ui.create_boxed_widget(habit_widget, dpi(550), dpi(500), beautiful.dash_widget_bg)

