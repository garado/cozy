
-- █▀ ▀█▀ ▄▀█ ▀█▀ █▀ 
-- ▄█ ░█░ █▀█ ░█░ ▄█ 

-- Shows CPU, RAM, and disk usage.
-- Credit: rxyhn

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi        = xresources.apply_dpi
local wibox   = require("wibox")
local watch   = require("awful.widget.watch")
local ui      = require("helpers.ui")
local control = require("core.cozy.control")

--- Helper function to create stats UI
-- @param name The stat label
local function create_stats_ui(name)
  local label = wibox.widget({
    forced_width = dpi(50),
    font   = beautiful.font_reg_s,
    markup = ui.colorize(name, beautiful.primary_0),
    align  = "right",
    widget = wibox.widget.textbox,
  })

  local percent = wibox.widget({
    forced_width = dpi(40),
    markup = ui.colorize("0%", beautiful.fg_0),
    font   = beautiful.font_reg_s,
    align  = "center",
    widget = wibox.widget.textbox,
  })

  local bar = wibox.widget({
    background_color = beautiful.bg_3,
    border_width  = dpi(0),
    forced_height = dpi(5),
    forced_width  = dpi(175),
    max_value = 100,
    color     = beautiful.primary_0,
    widget    = wibox.widget.progressbar
  })

  return wibox.widget({
    label,
    percent,
    {
      bar,
      widget = wibox.container.place,
    },
    spacing = dpi(7),
    layout  = wibox.layout.fixed.horizontal,
  })
end


-- █▀▀ █▀█ █░█ 
-- █▄▄ █▀▀ █▄█

local function cpu()
  local cpu_ui = create_stats_ui("cpu")
  local per = cpu_ui.children[2]
  local bar = cpu_ui.children[3].children[1]

	local _, cpu_timer = watch(
		[[sh -c "
		vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
		"]],
		5,
		function(_, stdout)
			local cpu_idle  = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
      local cpu_value = 100 - tonumber(cpu_idle)
      local mkup = ui.colorize(cpu_value.."%", beautiful.fg_0)

      bar.value = cpu_value
      per:set_markup_silently(mkup)

			collectgarbage("collect")
		end
	)

  return cpu_ui, cpu_timer
end


-- █▀█ ▄▀█ █▀▄▀█ 
-- █▀▄ █▀█ █░▀░█ 

local function ram()
  local ram_ui = create_stats_ui("ram")
  local per = ram_ui.children[2]
  local bar = ram_ui.children[3].children[1]

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
      local mkup  = ui.colorize(used_per .."%", beautiful.fg_0)

      bar.value = used_per
      per:set_markup_silently(mkup)

			collectgarbage("collect")
		end
	)

  return ram_ui, ram_timer
end


-- █▀▄ █ █▀ █▄▀
-- █▄▀ █ ▄█ █░█

local function disk()
  local disk_ui = create_stats_ui("hdd")
  local per = disk_ui.children[2]
  local bar = disk_ui.children[3].children[1]

  -- Update every 10 minutes
  local cmd = [[bash -c "df -h /home|grep '^/' | awk '{print $5}'"]]
	local _, disk_timer = watch(cmd, 600, function(_, stdout)
		local space_used = tonumber(stdout:match("(%d+)"))
    local mkup = ui.colorize(space_used.."%", beautiful.ctrl_fg)

    bar.value = space_used
    per:set_markup_silently(mkup)

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
  cpu_timer:start()
  ram_timer:start()
  ssd_timer:start()
end)

control:connect_signal("setstate::close", function()
  cpu_timer:stop()
  ram_timer:stop()
  ssd_timer:stop()
end)

return widget
