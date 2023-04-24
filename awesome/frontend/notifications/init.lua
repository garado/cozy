
-- █▄░█ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀
-- █░▀█ █▄█ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█

local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local menubar = require("menubar")
local animation = require("modules.animation")
local utils = require("utils")
local colorize = require("utils.ui").colorize

naughty.persistence_enabled = true
naughty.config.defaults.ontop = true
naughty.config.defaults.timeout = 5
naughty.config.defaults.title = "Notification"
naughty.config.defaults.position = "top_right"
naughty.config.defaults.auto_reset_timeout = true

local function get_oldest_notification()
  for _, notification in ipairs(naughty.active) do
    if notification then
      return notification
    end
  end

  -- fallback to first one
  return naughty.active[1]
end

-- icon
naughty.connect_signal("request::icon", function(n, context, hints)
	--- Handle other contexts here
	if context ~= "app_icon" then
		return
	end

	--- use xdg icon
	local path = menubar.utils.lookup_icon(hints.app_icon) or menubar.utils.lookup_icon(hints.app_icon:lower())

	if path then
		n.icon = path
	end
end)

--- Use XDG icon
naughty.connect_signal("request::action_icon", function(a, context, hints)
	a.icon = menubar.utils.lookup_icon(hints.id)
end)


naughty.connect_signal("request::display", function(n)
  local accent_color = beautiful.random_accent_color()
  n.font = beautiful.font_reg_s
  n.fg = beautiful.fg_0

	--- table of icons
	local app_icons = {
		["firefox"] = { icon = "" },
		["discord"] = { icon = "" },
		["music"] = { icon = "" },
		["screenshot tool"] = { icon = "" },
		["color picker"] = { icon = "" },
	}

	local app_icon = nil
	local tolow = string.lower

	if app_icons[tolow(n.app_name)] then
		app_icon = app_icons[tolow(n.app_name)].icon
	else
		app_icon = "d"
	end

	local icon = wibox.widget({
		{
			{
			  image = n.icon,
			  resize = true,
			  clip_shape = gears.shape.circle,
			  halign = "center",
			  valign = "center",
			  widget = wibox.widget.imagebox,
			},
      forced_width  = dpi(50),
      forced_height = dpi(50),
			border_width = dpi(2),
			border_color = accent_color,
			shape = gears.shape.circle,
			widget = wibox.container.background,
		},
		layout = wibox.layout.stack,
	})

  local title = wibox.widget({
    {
      markup = colorize(n.title, beautiful.fg_0),
      font   = beautiful.font_reg_s,
      widget = wibox.widget.textbox,
    },
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps    = 60,
    speed  = 75,
    widget = wibox.container.scroll.horizontal,
  })

  -- dumb hack - bright/vol notifs need to be replaceable
  local anim
  local message
  if n.title == "Brightness" or n.title == "Volume" then
    message = naughty.widget.message
  else
    message = wibox.widget({
      {
        markup  = colorize(n.message, beautiful.fg_0),
        font    = beautiful.font_reg_s,
        widget  = wibox.widget.textbox,
      },
      step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      fps    = 60,
      speed  = 100,
      widget = wibox.container.scroll.horizontal,
    })
  end

  local function action_layout(num_actions)
    if num_actions > 2 then
      return wibox.layout.flex.vertical
    else
      return wibox.layout.flex.horizontal
    end
  end

  local actions = wibox.widget({
		notification = n,
		base_layout = wibox.widget({
			spacing = dpi(3),
			layout = action_layout(#n.actions)
		}),
		widget_template = {
			{
				{
					{
						id = "text_role",
						font = beautiful.font_reg_xs,
						widget = wibox.widget.textbox,
					},
					left = dpi(6),
					right = dpi(6),
					widget = wibox.container.margin,
				},
				widget = wibox.container.place,
			},
			bg = beautiful.notif_actions_bg,
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

  local app_name = wibox.widget({
    markup = colorize(string.upper(n.app_name), accent_color),
    font   = beautiful.font_reg_xs,
    widget = wibox.widget.textbox,
  })

  local timeout_bar = wibox.widget ({
    widget = wibox.widget.progressbar,
		forced_height = dpi(3),
		max_value = 100,
		min_value = 0,
		value = 100,
		thickness = dpi(3),
    border_color = beautiful.notif_timeout_bg,
		background_color = beautiful.notif_timeout_bg,
    color = accent_color,
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
        {
          {
            {
              {
                app_name,
                nil,
                layout = wibox.layout.align.horizontal,
              },
              {
                {
                  icon,
                  utils.ui.hpad(dpi(15)),
                  visible = n.icon ~= nil,
                  layout = wibox.layout.fixed.horizontal,
                },
                {
                  {
                    title,
                    message,
                    spacing = dpi(2),
                    layout = wibox.layout.fixed.vertical,
                  },
                  widget = wibox.container.place,
                },
                layout = wibox.layout.fixed.horizontal,
              },
              spacing = dpi(5),
              layout = wibox.layout.fixed.vertical,
            },
            { -- actions
              utils.ui.vpad(dpi(10)),
              {
                actions,
                shape = utils.ui.rrect(beautiful.border_radius / 2),
                widget = wibox.container.background,
              },
              visible = n.actions and #n.actions > 0,
              layout = wibox.layout.fixed.vertical,
            }, -- end actions
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.margin,
          margins = {
            left = dpi(15),
            right = dpi(15),
            top = dpi(10),
            bottom = dpi(10),
          },
        },
        timeout_bar,
        layout = wibox.layout.fixed.vertical,
      },
      bg = beautiful.notif_bg,
      forced_width = dpi(275),
      widget = wibox.container.background,
    },
  })

  local function new_anim()
    return animation:new({
		  duration = n.timeout,
		  target = 0,
		  easing = animation.easing.linear,
		  reset_on_stop = false,
		  update = function(self, pos)
		  	timeout_bar.value = 100 - dpi(pos)
		  end
	  })
  end

  local anim = new_anim()

  awesome.connect_signal("module::volume", function()
    if n.title == "Volume" then
      timeout_bar.value = 100
      anim:stop()
      anim = new_anim()
      anim:set(100)
    end
  end)

  awesome.connect_signal("module::brightness", function()
    if n.title == "Brightness" then
      timeout_bar.value = 100
      anim:stop()
      anim = new_anim()
      anim:set(100)
    end
  end)

  if n.timeout > 0 then
    anim:set(100)
  end

  if n.title ~= "Volume" and n.title ~= "Brightness" then
    anim:connect_signal("ended", function()
      n:destroy()
    end)
  end

end)

require(... .. ".error")
require(... .. ".volume")
require(... .. ".brightness")
-- require(... .. ".battery")
-- require(... .. ".playerctl")
-- require(... .. ".volume")
-- require(... .. ".prompts")
