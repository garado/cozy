
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
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = "Notification"
naughty.config.defaults.position = "top_right"

local function get_oldest_notification()
  for _, notification in ipairs(naughty.active) do
    if notification and notification.timeout > 0 then
      return notification
    end
  end

  -- fallback to first one
  return naughty.active[1]
end

naughty.connect_signal("request::display", function(n)
  local accent_colors = beautiful.random_accent_color()

  local title = wibox.widget({
    widget = wibox.container.scroll.horizontal,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 60,
    speed = 75,
    widgets.text({
      font = beautiful.font_name,
      size = 10,
      bold = true,
      text = n.title,
    }),
  })


  local message = wibox.widget({
    widget = wibox.container.scroll.horizontal,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 60,
    speed = 100,
    widgets.text({
      font = beautiful.font,
      size = 10,
      bold = false,
      text = n.message,
    }),
  })
  
  local actions = wibox.widget({
		notification = n,
		base_layout = wibox.widget({
			spacing = dpi(3),
			layout = wibox.layout.flex.horizontal,
		}),
		widget_template = {
			{
				{
					{
						id = "text_role",
						font = beautiful.font .. "10",
						widget = wibox.widget.textbox,
					},
					left = dpi(6),
					right = dpi(6),
					widget = wibox.container.margin,
				},
				widget = wibox.container.place,
			},
			bg = beautiful.nord0,
			forced_height = dpi(25),
			forced_width = dpi(70),
			widget = wibox.container.background,
		},
		style = {
			underline_normal = false,
			underline_selected = true,
		},
		widget = naughty.list.actions,
  })

  local app_name = widgets.text({
    font = "Roboto Mono ",
    size = 10,
    bold = true,
    text = n.app_name,
  })

	local dismiss = widgets.button.text.normal({
		--font = beautiful.icon_font .. "Round ",
    font = beautiful.font,
		paddings = dpi(2),
		size = 9,
		bold = true,
		text = "",
    normal_bg = beautiful.notification_title_bg,
		text_normal_bg = accent_colors,
		animate_size = false,
		on_release = function()
			n:destroy(naughty.notification_closed_reason.dismissed_by_user)
		end,
	})

  local timeout_arc = wibox.widget({
    widget = wibox.container.arcchart,
		forced_width = dpi(26),
		forced_height = dpi(26),
		max_value = 100,
		min_value = 0,
		value = 0,
		thickness = dpi(4),
		rounded_edge = true,
		bg = beautiful.notification_bg,
		colors = {
			{
				type = "linear",
				from = { 0, 0 },
				to = { 400, 400 },
				stops = {
					{ 0, accent_colors },
					{ 0.2, accent_colors },
					{ 0.4, accent_colors },
					{ 0.6, accent_colors },
					{ 0.8, accent_colors },
				},
			},
		},
		dismiss,
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
        { -- App name
          {
            {
              app_name,
              nil,
              timeout_arc,
              layout = wibox.layout.align.horizontal,
            },
            margins = { 
              top = dpi(5), 
              bottom = dpi(5), 
              left = dpi(10), 
              right = dpi(10) 
            },
            widget = wibox.container.margin,
          },
          bg = beautiful.notification_title_bg,
          widget = wibox.container.background,
        }, -- End app name
        { -- Content
          {
            { -- app icon and title/msg
              layout = wibox.layout.fixed.horizontal,
              {
                layout = wibox.layout.fixed.horizontal,
                nil, -- icon goes here when i get around to adding it
              },
              {
                expand = "none",
                layout = wibox.layout.align.vertical,
                nil, --??
                {
                  layout = wibox.layout.fixed.vertical,
                  title,
                  message,
                },
                nil,
              },
            }, -- end app icon and title/msg
            { -- Actions
             	helpers.ui.vertical_pad(dpi(10)),
              {
                actions,
                shape = helpers.ui.rrect(beautiful.border_radius / 2),
                widget = wibox.container.background,
              },
              visible = n.actions and #n.actions > 0,
              layout = wibox.layout.fixed.vertical,
            }, -- End actions
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(10),
          widget = wibox.container.margin,
        }, -- End content
      },
      shape = helpers.ui.rrect(dpi(5)),
      bg = beautiful.notification_content_bg,
      forced_width = dpi(275),
      widget = wibox.container.background,
    },
  })

  -- Timeout arc animation
	local anim = animation:new({
		duration = n.timeout,
		target = 100,
		easing = animation.easing.linear,
		reset_on_stop = false,
		update = function(self, pos)
			timeout_arc.value = pos
		end,
	})

	anim:connect_signal("ended", function()
		n:destroy()
	end)

  anim:start()

end)


require(... .. ".error")
require(... .. ".battery")
require(... .. ".playerctl")
require(... .. ".brightness")
require(... .. ".volume")
require(... .. ".prompts")
