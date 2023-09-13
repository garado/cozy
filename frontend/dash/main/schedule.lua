
-- █▀ █▀▀ █░█ █▀▀ █▀▄ █░█ █░░ █▀▀
-- ▄█ █▄▄ █▀█ ██▄ █▄▀ █▄█ █▄▄ ██▄

-- Widget showing upcoming tasks and events.

local beautiful     = require("beautiful")
local ui            = require("utils.ui")
local dpi           = ui.dpi
local wibox         = require("wibox")
local cal           = require("backend.system.calendar")
local conf          = require("cozyconf")
local task          = require("backend.system.task")
local awful         = require("awful")
local strutil       = require("utils.string")
local truncate_fixed = require("utils.layout.truncate_fixed")

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀

local WIDGET_HEIGHT = dpi(520)

--- @function gen_date
-- @brief Generate container widget that holds tasks + events for a single date.
local function gen_date(date)
  local widget  = wibox.widget({
    ui.textbox({ -- Label with date
      text  = strutil.dt_convert(date, "%Y-%m-%d", "%A %B %d"),
      font  = beautiful.font_med_s,
      color = date == os.date("%Y-%m-%d") and beautiful.primary[400] or beautiful.neutral[300],
    }),
    { -- Separator
      forced_height = dpi(1),
      forced_width = dpi(200),
      bg = beautiful.neutral[600],
      widget = wibox.container.background,
    },
    {
      -- Events container
      spacing = dpi(3),
      layout = wibox.layout.fixed.vertical,
    },
    {
      -- Tasks container
      spacing = dpi(3),
      layout = wibox.layout.fixed.vertical,
    },
    spacing = dpi(6),
    layout = wibox.layout.fixed.vertical,
  })

  widget.date   = date
  widget.events = widget.children[3]
  widget.tasks  = widget.children[4]

  return widget
end

--- @function gen_event
-- @brief Generate event widget
-- @param data  Table containing event data
local function gen_event(data)
  local sidebar = wibox.widget({
    forced_width = dpi(4),
    shape = ui.rrect(),
    bg = beautiful.primary[400],
    widget = wibox.container.background,
  })

  local date_text
  if data[cal.START_TIME] == data[cal.END_TIME] then
    date_text = "All day"
  else
    date_text = data[cal.START_TIME]
  end

  -- Event title
  local toptext = wibox.widget({
    ui.textbox({
      text = data[cal.TITLE],
      font = beautiful.font_med_s,
    }),
    nil,
    ui.textbox({
      text = date_text
    }),
    forced_height = conf.font.sizes.s + dpi(4),
    forced_width = dpi(2000),
    layout = wibox.layout.align.horizontal,
  })

  -- Event location (if any)
  local bottext
  if data[cal.LOCATION] ~= "" then
    bottext = wibox.widget({
      ui.textbox({
        text = data[cal.LOCATION],
        color = beautiful.neutral[300],
      }),
      forced_width = dpi(2000),
      forced_height = conf.font.sizes.s + dpi(4),
      layout = wibox.layout.align.horizontal,
    })
  end

  return wibox.widget({
    sidebar,
    {
      {
        toptext,
        bottext,
        spacing = dpi(4),
        layout = wibox.layout.fixed.vertical,
      },
      top    = dpi(3),
      bottom = dpi(3),
      widget = wibox.container.margin,
    },
    spacing = dpi(6),
    layout = wibox.layout.fixed.horizontal,
  })
end

--- @function gen_task
-- @brief Generate task widget
-- @param data  Table containing task data
local function gen_task(data)
  local cbox = ui.textbox({
    text = data.status == "pending" and "󰄱" or "󰱒"
  })

  local desc = ui.textbox({
    text = data.description,
    strikethrough = data.status == "completed"
  })

  local tag = wibox.widget({
    {
      ui.textbox({
        text = data.tags and data.tags[1] or "",
        font = beautiful.font_med_xs,
      }),
      margins = dpi(4),
      widget = wibox.container.margin,
    },
    shape = ui.rrect(dpi(4)),
    bg = beautiful.primary[700],
    widget = wibox.container.background,
  })

  local widget = wibox.widget({
    cbox,
    tag,
    desc,
    spacing = dpi(4),
    forced_height = dpi(20),
    layout = wibox.layout.fixed.horizontal,
    ---
    uuid = data.uuid,
    pending = data.status == "pending"
  })

  widget:connect_signal("button::press", function()
    local cmd = "task "..widget.uuid.." mod status:" .. (widget.pending and "completed" or "pending")
    awful.spawn.easy_async_with_shell(cmd, function() task:emit_signal("refresh") end)
  end)

  return widget
end

-- This is where all the date containers get added
local schedule = wibox.widget({
  spacing = dpi(12),
  forced_width = dpi(1000),
  forced_height = WIDGET_HEIGHT,
  layout = truncate_fixed.vertical,
})

--- @method create_date
-- @brief Create a new date container and insert it into the widget hierarchy in the
--        correct chronological order. If the date already exists, return the existing
--        container.
-- @param date  Date as a string in YYYY-mm-dd format
-- @return date container widget
function schedule:create_date(date)
  -- Check for preexisting date
  for i = 1, #self.children do
    if self.children[i].date == date then return self.children[i] end
  end

  -- Make a new one otherwise
  local d = gen_date(date)

  -- Add in correct order
  if #self.children == 0 then
    self:add(d)
    return d
  else
    for i = 1, #self.children do
      if date < self.children[i].date then
        self:insert(i, d)
        return d
      end
    end
  end

  self:add(d)
  return d
end

function schedule:clear_events()
  for i = 1, #self.children do
    self.children[i].events:reset()
  end
end

function schedule:clear_tasks()
  for i = 1, #self.children do
    self.children[i].tasks:reset()
  end
end

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

-- We get data from 2 separate async calls, one for tasks and one for events

-- Function to add events once they're ready
local function add_events(_, events)
  schedule:clear_events()
  for i = 1, #events do
    local d = schedule:create_date(events[i][cal.START_DATE])
    d.events:add(gen_event(events[i]))
  end
end

-- Function to add tasks once they're ready
local function add_tasks(_, tasks)
  schedule:clear_tasks()
  for i = 1, #tasks do
    -- Convert from ISO to YYYY-mm-dd
    local date = strutil.dt_convert(tasks[i].due, strutil.dt_format.iso, "%Y-%m-%d")
    local d = schedule:create_date(date)
    d.tasks:add(gen_task(tasks[i]))
  end
end

cal:connect_signal("cache::ready", function()
  cal:fetch_upcoming("main")
end)

task:connect_signal("refresh", function()
  task:fetch_upcoming()
end)

cal:connect_signal("ready::upcoming::main", add_events)
task:connect_signal("ready::due::upcoming", add_tasks)

-- Now finally request the data
cal:fetch_upcoming("main")
task:fetch_upcoming()

local tmp = ui.dashbox_v2(schedule)
tmp.forced_height = WIDGET_HEIGHT
return tmp
