
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
    helpers.ui.create_dash_widget_header("Habits"),
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

-- update cache for a graph
local function update_cache(graph_id, date, set_as_complete)
  local file = gfs.get_cache_dir() .. "pixela/" .. graph_id
  awful.spawn.easy_async_with_shell("cat " .. file, function(stdout)
    if set_as_complete then
      -- if habit is already completed in cache, do nothing
      if string.find(stdout, date) ~= nil then 
        return
      -- else, mark as completed by writing date to cache
      else
        stdout = stdout .. " " .. date
        cmd = "echo '" .. stdout .. "' > " .. file
        awful.spawn.with_shell(cmd)
      end
    -- if we want to set a habit as not completed
    elseif not set_as_complete then
      stdout = string.gsub(stdout, date, "")
      stdout = string.gsub(stdout, "[(\n\r)+]", "")
      cmd = "echo '" .. stdout .. "' > " .. file
      awful.spawn.with_shell(cmd)
    end
  end)
end

local function update_pixela(graph_id, date, qty)
  local pi_cmd = "pi pixel update -g " .. graph_id .. " -d " .. date .. " -q " .. qty
  awful.spawn.easy_async_with_shell(pi_cmd, function(stdout)
    -- pixela api returns api request status -- check that
    if string.find(stdout, "Success.") ~= nil then
      local state = qty == 1 and "complete" or qty == 0 and "not complete"
      naughty.notification {
        app_name = "System notification",
        title = "Pixela API",
        message = "Successfully set " .. graph_id .. " as " .. state,
      }
    else
      naughty.notification {
        app_name = "System notification",
        title = "Pixela API",
        message = "Setting " .. graph_id .. " as " .. state .. " failed",
        timeout = 0,
      }
    end
  end)
end

-- populates habit_widget with habits
local function create_habit_ui()
  -- creates just one habit
  local function create_habit_ui_entry(habit_name, graph_id, frequency)
    local habit_name = wibox.widget({
      markup = helpers.ui.colorize_text(habit_name, beautiful.fg),
      font = beautiful.font_name .. "12",
      align = "right",
      valign = "center",
      widget = wibox.widget.textbox,
    })

    local freq = wibox.widget({
      markup = helpers.ui.colorize_text(frequency, beautiful.habit_freq),
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

        local checked, text_color, qty
        if string.find(stdout, date) ~= nil then
          -- habit was completed 
          checked = true
          text_color = beautiful.hab_check_fg
          qty = 0 -- pressing button will set habit to this value
        else
          checked = false
          text_color = beautiful.hab_uncheck_fg
          qty = 1
        end

        -- assemble checkbox
        local checkbox_text = os.date("%a", i_days_ago)
        checkbox_text = string.sub(checkbox_text, 1, 1)
        local checkbox = wibox.widget({
          {
            checked = checked,
            forced_height = dpi(20),
            border_width = dpi(0),
            check_shape = gears.shape.circle,
            check_color = beautiful.hab_check_bg,
            bg = beautiful.hab_uncheck_bg,
            paddings = dpi(0),
            shape = gears.shape.circle,
            widget = wibox.widget.checkbox,
          },
          {
            markup = helpers.ui.colorize_text(checkbox_text, text_color),
            font = beautiful.font .. "11",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox,
          },
          layout = wibox.layout.stack,
        })

        checkbox:connect_signal("button::press", function()
          -- update ui
          local box = checkbox.children[1]
          box.checked = not box.checked
          local text_color = box.checked and beautiful.hab_check_fg
              or not box.checked and beautiful.hab_uncheck_fg
          local text = checkbox.children[2]
          text.markup = helpers.ui.colorize_text(checkbox_text, text_color)


          -- update data
          update_pixela(graph_id, date, qty)
          update_cache(graph_id, date, box.checked)
          if qty == 1 then qty = 0 end
          if qty == 0 then qty = 1 end
        end)

        days:add(checkbox)
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

return helpers.ui.create_boxed_widget(habit_widget, dpi(550), dpi(400), beautiful.dash_widget_bg)

