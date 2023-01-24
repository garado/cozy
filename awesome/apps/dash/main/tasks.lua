
-- ▀█▀ ▄▀█ █▀ █▄▀ █▀
-- ░█░ █▀█ ▄█ █░█ ▄█

-- Integrated with Taskwarrior!

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local json  = require("modules.json")

local box       = require("helpers.ui").create_boxed_widget
local colorize  = require("helpers.ui").colorize_text
local wheader   = require("helpers.ui").create_dash_widget_header
local math  = math
local os    = os

local function widget()
  local header = wibox.widget({
    wheader("Tasks"),
    margins = dpi(5),
    widget = wibox.container.margin,
  })

  local task_list = wibox.widget({
    wibox.widget({
      markup = colorize("No tasks found", beautiful.fg),
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    }),
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  })

  -- currently tag, proj are unused
  local function create_task(desc, due, urg, tag, proj)
    local function format_due_date(due)
      -- taskwarrior returns due date as string
      -- convert that to a lua timestamp
      local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
      local xyear, xmon, xday, xhr, xmin, xsec = due:match(pattern)
      local ts = os.time({
        year = xyear, month = xmon, day = xday,
        hour = xhr, min = xmin, sec = xsec })

      -- turn timestamp into human-readable format
      local now = os.time()
      local time_difference = ts - now
      local abs_time_difference = math.abs(time_difference)
      local days_rem = math.floor(abs_time_difference / 86400)
      local hours_rem = math.floor(abs_time_difference / 3600)

      -- due date formatting
      local due_date_text
      if days_rem >= 1 then -- in x days / x days ago
        due_date_text = days_rem .. " day"
        if days_rem > 1 then
          due_date_text = due_date_text .. "s"
        end
      else -- in x hours / in <1 hour / etc
        if hours_rem == 1 then
          due_date_text = hours_rem .. " hour"
        elseif hours_rem < 1 then
          due_date_text = "&lt;1 hour"
        else
          due_date_text = hours_rem .. " hours"
        end
      end

      if time_difference < 0 then -- overdue
        due_date_text = due_date_text .. " ago"
      else
        due_date_text = "in " .. due_date_text
      end

      return due_date_text
    end

    local due_date_text
    if due then
      due_date_text = format_due_date(due)
    else
      due_date_text = "no due date"
    end

    -- more urgent tasks should be red
    local desc_color = beautiful.fg
    if urg > 7 then
      desc_color = beautiful.red
    end

    -- assemble widget
    local description = wibox.widget({
      markup = colorize(desc, desc_color),
      align = "left",
      widget = wibox.widget.textbox,
      ellipsize = "end",
      forced_width = dpi(360),
    })

    local due_ = wibox.widget({
      markup = colorize(due_date_text, beautiful.task_due_fg),
      align = "right",
      widget = wibox.widget.textbox,
    })

    local task = wibox.widget({
      description,
      nil,
      due_,
      layout = wibox.layout.align.horizontal,
    })

    task_list:add(task)
  end

  -- use `task export` to get task json, 
  -- then convert that to a table
  local function update_tasks()
    local cmd = "task limit:8 due.before:7d status:pending export rc.json.array=on"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local empty_json = "[\n]\n"
      if stdout ~= empty_json and stdout ~= "" then
        task_list:remove(1) -- remove placeholder
        local tasks = json.decode(stdout)
        for i, _ in ipairs(tasks) do
          local desc = tasks[i]["description"]
          local due  = tasks[i]["due"]
          local urg  = tasks[i]["urgency"]
          local tag  = tasks[i]["tag"]
          local proj = tasks[i]["project"]
          create_task(desc, due, urg, tag, proj)
        end
      end
    end)
  end

  -- this signal is emitted in a taskwarrior hook
  -- instructions to configure this are in the install guide
  awesome.connect_signal("widget::update_tasks", function()
    task_list:reset()
    update_tasks()
  end)

  update_tasks()

  -- assemble everything 
  local task_widget = wibox.widget({
    header,
    {
      task_list,
      margins = dpi(5),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.fixed.vertical,
  })

  return task_widget
end

return box(widget(), dpi(220), dpi(190), beautiful.dash_widget_bg)
