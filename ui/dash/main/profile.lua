
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")

local function create_profile()
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
    font = "Roboto Mono 18",
    align = "center",
    valign = "center",
  })
  
  local host = wibox.widget({
    widget = wibox.widget.textbox,
    markup = helpers.ui.colorize_text("@andromeda", beautiful.nord1),
    font = "Roboto Mono 18",
    align = "center",
    valign = "center",
  })
  
  local title = wibox.widget({
    widget = wibox.widget.textbox,
    font = beautiful.font .. "11",
    markup = "insert title here",
    align = "center",
    valign = "center",
  })
 
  -- new title every time you open dash
  -- need to make it change only when dash is closing
  awesome.connect_signal("dash::toggle", function()
    local naughty = require("naughty")
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
  
  local profile = wibox.widget({
    {
      image,
      --{
      --  --name
      --  --host,
      --  --spacing = dpi(2),
      --  layout = wibox.layout.fixed.horizontal,
      --},
      name,
      title, 
      spacing = dpi(2),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return profile 
end

return helpers.ui.create_boxed_widget(create_profile(), dpi(400), dpi(180), beautiful.dash_bg)

