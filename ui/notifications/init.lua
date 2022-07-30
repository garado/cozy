
-- █▄░█ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
-- █░▀█ █▄█ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█
---------------- Credit: @rxyhn -----------------

local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local helpers = require("helpers")
local menubar = require("menubar")
local animation = require("modules.animation")
local widgets = require("ui.widgets")

naughty.persistence_enabled = true
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 6
naughty.config.defaults.title = "Notification"

local function get_oldest_notification()
  for _, notification in ipairs(naughty.active) do
    if notification and notification.timeout > 0 then
      return notification
    end
  end

  -- fallback to first one
  return naughty.active[1]
end

---- Handle notification icon
--naughty.connect_signal("request::icon", function(n, context, hints)
--  --- Handle other contexts here
--	if context ~= "app_icon" then
--		return
--	end
--
--	--- Use XDG icon
--	--local path = menubar.helpers.lookup_icon(hints.app_icon) or menubar.helpers.lookup_icon(hints.app_icon:lower())
--
--  local path = ""
--	if path then
--		n.icon = path
--	end
--end)

naughty.connect_signal("request::display", function(n)
  local message = wibox.widget({
    widget = wibox.container.scroll.horizontal,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 60,
    speed = 75,
    widgets.text({
      font = beautiful.font_name,
      size = 11,
      text = n.message,
    })
  })
	
  local title = wibox.widget({
		widget = wibox.container.scroll.horizontal,
		step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
		fps = 60,
		speed = 75,
		widgets.text({
			font = beautiful.font_name,
			size = 11,
			bold = true,
			text = n.title,
		}),
	})

  local widget = naughty.layout.box({
    notification = n,
    type = "notification",
    cursor = "hand2",

    shape = gears.shape.rectangle,
    maximum_width = dpi(350),
    maximum_height = dpi(180),
    bg = "#00000000",

    widget_template = {
      {
        layout = wibox.layout.fixed.vertical,
        {
          widget = wibox.container.background,
        },
        {
          {
            layout = wibox.fixed.vertical,
            {
              layout = wibox.fixed.horizontal,
              spacing = dpi(10),
              --icon,
              {
                expand = "none",
                layout = wibox.layout.align.vertical,
                nil,
                {
                  layout = wibox.layout.fixed.vertical,
                  title,
                  message,
                },
                nil,
              },
            },
            --{
            --  helpers.ui.vertical_pad(dpi(10)),
            --  {

            --  }
            --},
          },
          margins = dpi(15),
          widget = wibox.container.margin,
        },
      },
      shape = helpers.ui.rrect(beautiful.border_radius),
      bg = beautiful.notification_bg,
      widget = wibox.container.background,
    },
  })
end)

