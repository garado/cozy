
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")

local function widget(s)
  local image = wibox.widget({
    {
      {
        {
          image = beautiful.pfp,
          resize = true,
          clip_shape = gears.shape.circle,
          halign = "center",
          valign = "center",
          widget = wibox.widget.imagebox,
        },
        border_width = dpi(3),
        border_color = beautiful.nord10,
        shape = gears.shape.circle,
        widget = wibox.container.background,
      },
      strategy = "exact",
      forced_width = dpi(100),
      forced_height = dpi(100),
      widget = wibox.container.constraint,
    },
    { -- whyyyyy tf do we need this
			nil,
			nil,
			{
				nil,
				nil,
				icon,
				layout = wibox.layout.align.horizontal,
				expand = "none",
			},
			layout = wibox.layout.align.vertical,
			expand = "none",
		},
		layout = wibox.layout.stack,
  })

  local name = wibox.widget({
    widget = wibox.widget.textbox,
    markup = helpers.ui.colorize_text("Alexis G.", beautiful.nord10),
    font = beautiful.header_font .. "20",
    align = "left",
    valign = "center",
  })
  
  local host = wibox.widget({
    widget = wibox.widget.textbox,
    markup = helpers.ui.colorize_text("@andromeda", beautiful.nord1),
    font = beautiful.font .. "10",
    align = "left",
    valign = "center",
  })
  
  local title = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font .. "11",
    markup = "insert title here",
    align = "left",
    valign = "center",
  })
 
  -- new title every time you open dash
  awesome.connect_signal("dash::toggle", function()
    awful.spawn.easy_async_with_shell(
      [[
        $HOME/.config/awesome/utils/dash/main/get_random_title
      ]],
      function(stdout)
        local stdout = helpers.ui.colorize_text(stdout, beautiful.dash_widget_fg)
        title:set_markup(stdout)
      end
    )
  end)
  
  profile = wibox.widget({
    {
      image,
      {
        {
          {
            {
              name,
              host,
              spacing = dpi(-5),
              layout = wibox.layout.fixed.vertical,
            },
            title,
            spacing = dpi(5),
            layout = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.place,
        },
        margins = { left = dpi(15) },
        widget = wibox.container.margin,
      },
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })

  return profile 
end

return helpers.ui.create_boxed_widget(widget(), dpi(400), dpi(120), beautiful.dash_bg)

