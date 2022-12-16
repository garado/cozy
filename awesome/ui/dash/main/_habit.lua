
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀
-- █▀█ █▀█ █▄█ █ ░█░ ▄█

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local config = require("config")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text

local pixela = require("core.system.pixela")

local Area = require("modules.keynav.area")
local Habit = require("modules.keynav.navitem").Habit
local Dashwidget = require("modules.keynav.navitem").Dashwidget

local nav_dash_habits = Area:new({
  name = "nav_dash_habits",
  circular = true,
  is_grid_container = true,
})

-- habits get appended here later
local habit_list = config.habit
local habit_widget = wibox.widget({
  {
    --helpers.ui.create_dash_widget_header("Habits"),
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

local function update_pixela_err_handling(stderr)
  if string.find(stderr, "command not found") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela 'pi' command not found",
      timeout = 0,
    }
  elseif string.find(stderr, "Please specify username") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela username not found - set this in config",
      timeout = 0,
    }
  elseif string.find(stderr, "Please specify password") then
    naughty.notification {
      app_name = "System Notification",
      title = "Pixela API",
      message = "Pixela password not found - set this in config",
      timeout = 0,
    }
  end
end

local function update_pixela(graph_id, date, qty)
  local set_pixela_user, set_pixela_token
  if config.pixela then
    set_pixela_user = "export PIXELA_USER_NAME=" .. config.pixela.user
    set_pixela_token = "export PIXELA_USER_TOKEN=" .. config.pixela.token
  end

  local graph_id_cmd = " -g " .. graph_id
  local date_cmd     = " -d " .. date
  local qty_cmd      = " -q " .. qty
  local pi_cmd = "~/go/bin/pi pixel update" .. graph_id_cmd .. date_cmd .. qty_cmd
  local cmd = set_pixela_user .. " ; " .. set_pixela_token .. " ; " .. pi_cmd
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    -- Handle command errors
    if stderr ~= "" then
      update_pixela_err_handling(stderr)
      return
    end

    -- Pixela api returns api request status -- check for success
    local state = qty == 1 and "complete" or qty == 0 and "not complete"
    if string.find(stdout, "Success") then
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
        local cmd = "echo '" .. stdout .. "' > " .. file
        awful.spawn.with_shell(cmd)
        update_pixela(graph_id, date, 1)
      end
    -- if we want to set a habit as not completed
    elseif not set_as_complete then
      stdout = string.gsub(stdout, date, "")
      stdout = string.gsub(stdout, "[(\n\r)+]", "")
      local cmd = "echo '" .. stdout .. "' > " .. file
      awful.spawn.with_shell(cmd)
      update_pixela(graph_id, date, 0)
    end
  end)
end

-- creates just one habit
local function create_habit_ui_entry(name, graph_id, frequency)
  local nav_habit = Area:new({
    name = name,
    is_row = true,
    circular = true,
    row_wrap_vertical = true,
  })

  local habit_name = wibox.widget({
    markup = colorize(name, beautiful.fg),
    font = beautiful.font_name .. "12",
    align = "right",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local freq = wibox.widget({
    markup = colorize(frequency, beautiful.hab_freq),
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
      local checkbox_text = tostring(os.date("%a", i_days_ago))
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
          markup = colorize(checkbox_text, text_color),
          font = beautiful.font .. "11",
          align = "center",
          valign = "center",
          widget = wibox.widget.textbox,
        },
        layout = wibox.layout.stack,
      })

      nav_habit:append(Habit:new(checkbox))

      checkbox:connect_signal("button::press", function()
        -- update ui
        local box = checkbox.children[1]
        box.checked = not box.checked
        local text_color = box.checked and beautiful.hab_check_fg
            or not box.checked and beautiful.hab_uncheck_fg
        local text = checkbox.children[2]
        text.markup = colorize(checkbox_text, text_color)


        -- update data
        update_cache(graph_id, date, box.checked)
        qty = not qty
      end)

      days:add(checkbox)
    end -- end for
    nav_dash_habits:append(nav_habit)
    habit_widget.children[1]:add(habit_entry)
  end) -- end async
end -- end create_habit_entry

pixela:connect_signal("update::habits", function(_, graph_id)
  local id = graph_id
  local name = habit_list[graph_id][1]
  local freq = habit_list[graph_id][2]
  create_habit_ui_entry(name, id, freq)
end)

local container = box(habit_widget, dpi(550), dpi(410), beautiful.dash_widget_bg)
nav_dash_habits.widget = Dashwidget:new(container)

return function()
  return nav_dash_habits, container
end

