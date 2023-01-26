
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- Shows CPU, RAM, and disk usage.
-- Credit: rxyhn

local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local watch = require("awful.widget.watch")
local control = require("core.cozy.control")

--- Helper function to create UI.
-- @param name The label
-- @param accent_color The... accent color
local function create_stats_ui(name, accent_color)
  local label = wibox.widget({
    markup = colorize(name, accent_color),
    align = "right",
    valign = "center",
    forced_width = dpi(50),
    widget = wibox.widget.textbox,
  })

  local percent = wibox.widget({
    markup = colorize("0%", beautiful.ctrl_fg),
    align = "center",
    valign = "center",
    forced_width = dpi(40),
    widget = wibox.widget.textbox,
  })

  local bar = wibox.widget({
    border_width = dpi(0),
    color = accent_color,
    background_color = beautiful.ctrl_stats_bg,
    max_value = 100,
    forced_height = dpi(5),
    forced_width = dpi(175),
    widget = wibox.widget.progressbar
  })

  return wibox.widget({
    label,
    percent,
    {
      bar,
      widget = wibox.container.place,
    },
    spacing = dpi(7),
    layout = wibox.layout.fixed.horizontal,
  })
end

-- █▀▀ █▀█ █░█ 
-- █▄▄ █▀▀ █▄█ 
local function cpu()
  local ui = create_stats_ui("cpu", beautiful.ctrl_cpu_accent)
  local percent = ui.children[2]
  local bar = ui.children[3].children[1]

	local _, cpu_timer = watch(
		[[sh -c "
		vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
		"]],
		5,
		function(_, stdout)
			local cpu_idle = stdout
			cpu_idle = string.gsub(cpu_idle, "^%s*(.-)%s*$", "%1")
      local cpu_value = 100 - tonumber(cpu_idle)
      bar.value = cpu_value
      local markup = colorize(cpu_value.."%", beautiful.ctrl_fg)
      percent:set_markup_silently(markup)
			collectgarbage("collect")
		end
	)

  control:connect_signal("newstate::opened", function()
    if not cpu_timer.started then
      cpu_timer:start()
    end
  end)

  control:connect_signal("newstate::closed", function()
    cpu_timer:stop()
  end)

  return ui
end

-- █▀█ ▄▀█ █▀▄▀█ 
-- █▀▄ █▀█ █░▀░█ 
local function ram()
  local ui = create_stats_ui("ram", beautiful.ctrl_ram_accent)
  local percent = ui.children[2]
  local bar = ui.children[3].children[1]

  local _, ram_timer = watch(
		[[sh -c "
		free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
		"]],
		20,
		function(_, stdout)
			local available = stdout:match("(.*)@@")
			local total = stdout:match("@@(.*)@")
			local used = tonumber(total) - tonumber(available)
			local used_ram_percentage = (used / total) * 100
      used_ram_percentage = math.floor(used_ram_percentage)
      bar.value = used_ram_percentage
      local markup = colorize(used_ram_percentage.."%", beautiful.ctrl_fg)
      percent:set_markup_silently(markup)
			collectgarbage("collect")
		end
	)

  control:connect_signal("newstate::opened", function()
    if not ram_timer.started then
      ram_timer:start()
    end
  end)

  control:connect_signal("newstate::closed", function()
    ram_timer:stop()
  end)

  return ui
end

-- █▀▄ █ █▀ █▄▀ 
-- █▄▀ █ ▄█ █░█ 
local function disk()
  local ui = create_stats_ui("hdd", beautiful.ctrl_hdd_accent)
  local percent = ui.children[2]
  local bar = ui.children[3].children[1]

  -- Update every 10 minutes
  local cmd = [[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]]
	local _, disk_timer = watch(cmd, 600, function(_, stdout)
		local space_consumed = stdout:match("(%d+)")
    bar.value = tonumber(space_consumed)
    local markup = colorize(space_consumed.."%", beautiful.ctrl_fg)
    percent:set_markup_silently(markup)
		collectgarbage("collect")
	end)

  control:connect_signal("newstate::opened", function()
    if not disk_timer.started then
      disk_timer:start()
    end
  end)

  control:connect_signal("newstate::closed", function()
    disk_timer:stop()
  end)

  return ui
end

local widget = wibox.widget({
  {
    cpu(),
    ram(),
    disk(),
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

return widget
