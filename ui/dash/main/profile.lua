
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local utils = require("utils")

local function widget(s)
  local image = wibox.widget({
    {
      {
        {
          image = "/home/alexis/Pictures/Pepes/pepe_hacker.gif",
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
      forced_width = dpi(200),
      forced_height = dpi(200),
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
    markup = utils.ui.colorize_text("Alexis", beautiful.nord10),
    font = beautiful.font .. "20",
    --font = beautiful.font_name .. "Bold 18",
    align = "center",
    valign = "center",
  })
  
  local host = wibox.widget({
    widget = wibox.widget.textbox,
    markup = utils.ui.colorize_text("@andromeda", beautiful.xforeground),
    font = beautiful.font .. "10",
    --font = beautiful.font_name .. "Bold 10",
    align = "center",
    valign = "center",
  })
  
  local title = wibox.widget({
    widget = wibox.widget.textbox,
    markup = utils.ui.colorize_text("Resident Mechromancer", beautiful.xforeground),
    font = beautiful.font .. "15",
    --font = beautiful.font_name .. "Bold 11",
    align = "center",
    valign = "center",
  })
  
  profile = wibox.widget({
    image,
    {
      {
        {
          {
            name,
            host,
            layout = wibox.layout.align.vertical,
          },
          margins = { bottom = dpi(11) },
          widget = wibox.container.margin,
        },
        title,
        layout = wibox.layout.align.vertical,
      },
      margins = { top = dpi(5) },
      widget = wibox.container.margin,
    },
    layout = wibox.layout.fixed.vertical,
  })

  return profile 
end

return utils.ui.create_boxed_widget(widget(), dpi(300), dpi(330), beautiful.background_med)

