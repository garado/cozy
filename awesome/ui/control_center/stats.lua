
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- cpu, ram, disk usage
-- credit: rxyhn

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local watch = awful.widget.watch

local function create_stats_ui(name, accent_color)
  local label = wibox.widget({
    markup = helpers.ui.colorize_text(name, accent_color),
    align = "right",
    valign = "center",
    forced_width = dpi(50),
    widget = wibox.widget.textbox,
  })

  local percent = wibox.widget({
    markup = helpers.ui.colorize_text("0%", beautiful.ctrl_fg),
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

	watch(
		[[sh -c "
		vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
		"]],
		5,
		function(_, stdout)
			local cpu_idle = stdout
			cpu_idle = string.gsub(cpu_idle, "^%s*(.-)%s*$", "%1")
      local cpu_value = 100 - tonumber(cpu_idle)
      bar.value = cpu_value
      local markup = helpers.ui.colorize_text(cpu_value.."%", beautiful.ctrl_fg)
      percent:set_markup_silently(markup)
			collectgarbage("collect")
		end
	)

  return ui
end

-- █▀█ ▄▀█ █▀▄▀█ 
-- █▀▄ █▀█ █░▀░█ 
local function ram()
  local ui = create_stats_ui("ram", beautiful.ctrl_ram_accent)
  local percent = ui.children[2]
  local bar = ui.children[3].children[1]

  watch(
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
      local markup = helpers.ui.colorize_text(used_ram_percentage.."%", beautiful.ctrl_fg)
      percent:set_markup_silently(markup)
			collectgarbage("collect")
		end
	)

  return ui
end

-- █▀▄ █ █▀ █▄▀ 
-- █▄▀ █ ▄█ █░█ 
local function disk()
  local ui = create_stats_ui("hdd", beautiful.ctrl_hdd_accent)
  local percent = ui.children[2]
  local bar = ui.children[3].children[1]

  local cmd = [[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]]
	watch(cmd, 180, function(_, stdout)
		local space_consumed = stdout:match("(%d+)")
    bar.value = tonumber(space_consumed)
    local markup = helpers.ui.colorize_text(space_consumed.."%", beautiful.ctrl_fg)
    percent:set_markup_silently(markup)
		collectgarbage("collect")
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
