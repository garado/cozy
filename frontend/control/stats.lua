
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- Shows CPU, RAM, and disk usage.
-- Credit: rxyhn

local beautiful  = require("beautiful")
local ui      = require("utils.ui")
local dpi     = ui.dpi
local wibox   = require("wibox")
local watch   = require("awful.widget.watch")
local control = require("backend.cozy.control")

--- Helper function to create stats UI
-- @param name The stat label
local function create_stats_ui(name)
  local label = ui.textbox({
    text  = name,
    color = beautiful.primary[400],
    width = dpi(50),
    align = "right",
  })

  local percent = ui.textbox({
    text  = "--%",
    width = dpi(40),
    color = beautiful.neutral[100],
    align = "center",
  })

  local bar = wibox.widget({
    background_color = beautiful.neutral[600],
    border_width  = dpi(0),
    forced_height = dpi(5),
    forced_width  = dpi(175),
    max_value = 100,
    color  = beautiful.primary[500],
    widget = wibox.widget.progressbar
  })

  local entry = wibox.widget({
    label,
    percent,
    {
      bar,
      widget = wibox.container.place,
    },
    spacing = dpi(8),
    layout  = wibox.layout.fixed.horizontal,
  })

  -- Keep references accessible for later
  entry.bar = bar
  entry.label = label
  entry.percent = percent

  return entry
end


-- █▀▀ █▀█ █░█ 
-- █▄▄ █▀▀ █▄█

local function cpu()
  local cpu_ui = create_stats_ui("cpu")
  local per = cpu_ui.percent
  local bar = cpu_ui.bar

	local _, cpu_timer = watch(
		[[sh -c "
		vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
		"]],
		5,
		function(_, stdout)
		  local cpu_idle  = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
      local cpu_value = 100 - tonumber(cpu_idle)

      per:update_text(cpu_value.."%")
      bar.value = cpu_value

			collectgarbage("collect")
		end
	)

  return cpu_ui, cpu_timer
end


-- █▀█ ▄▀█ █▀▄▀█ 
-- █▀▄ █▀█ █░▀░█ 

local function ram()
  local ram_ui = create_stats_ui("ram")
  local per = ram_ui.percent
  local bar = ram_ui.bar

  local _, ram_timer = watch(
		[[sh -c "
		free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
		"]],
		20,
		function(_, stdout)
			local avail = stdout:match("(.*)@@")
			local total = stdout:match("@@(.*)@")
			local used  = tonumber(total) - tonumber(avail)
			local used_per = math.floor((used / total) * 100)

      bar.value = used_per
      per:update_text(used_per .. "%")

			collectgarbage("collect")
		end
	)

  return ram_ui, ram_timer
end


-- █▀▄ █ █▀ █▄▀
-- █▄▀ █ ▄█ █░█

local function disk()
  local disk_ui = create_stats_ui("hdd")
  local per = disk_ui.percent
  local bar = disk_ui.bar

  -- Update every 10 minutes
  local cmd = [[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]]
	local _, disk_timer = watch(cmd, 600, function(_, stdout)
		local space_used = tonumber(stdout:match("(%d+)"))

    bar.value = space_used
    per:update_text(space_used.."%")

		collectgarbage("collect")
	end)

  return disk_ui, disk_timer
end

local cpu_ui, cpu_timer = cpu()
local ram_ui, ram_timer = ram()
local ssd_ui, ssd_timer = disk()

local widget = wibox.widget({
  {
    cpu_ui,
    ram_ui,
    ssd_ui,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

control:connect_signal("setstate::open", function()
  if not cpu_timer.started then cpu_timer:start() end
  if not ram_timer.started then ram_timer:start() end
  if not ssd_timer.started then ssd_timer:start() end
end)

control:connect_signal("setstate::close", function()
  cpu_timer:stop()
  ram_timer:stop()
  ssd_timer:stop()
	collectgarbage("collect")
end)

return widget
