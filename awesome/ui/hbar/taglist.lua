
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local cairo = require("lgi").cairo
local colorize    = require("helpers.ui").colorize_text
local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local animation = require("modules.animation")
local dpi       = xresources.apply_dpi

return function(s)
  local modkey = "Mod4"
  local taglist_buttons = gears.table.join(
  	awful.button({}, 1, function(t)
  		t:view_only()
  	end),
  	awful.button({ modkey }, 1, function(t)
  		if client.focus then
  			client.focus:move_to_tag(t)
  		end
  	end),
  	awful.button({}, 3, awful.tag.viewtoggle),
  	awful.button({ modkey }, 3, function(t)
  		if client.focus then
  			client.focus:toggle_tag(t)
  		end
  	end),
  	awful.button({}, 4, function(t)
  		awful.tag.viewnext(t.screen)
  	end),
  	awful.button({}, 5, function(t)
  		awful.tag.viewprev(t.screen)
  	end)
  )

  local bar = wibox.widget({
    {
      forced_height = dpi(3),
      forced_width  = dpi(30),
      bg     = beautiful.main_accent,
      widget = wibox.container.background,
    },
    left   = dpi(30*0),
    widget = wibox.container.margin,
  })

	local taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = { layout = wibox.layout.fixed.horizontal },
		widget_template = {
			widget = wibox.container.margin,
			forced_width  = dpi(30),
			create_callback = function(self, c3, _)
				local indicator = wibox.widget({
          {
            markup = colorize(c3.name, beautiful.wibar_fg),
            font   = beautiful.base_xsmall_font,
            align  = "center",
            valign = "center",
            widget = wibox.widget.textbox,
          },
          widget = wibox.container.place,
				})

        self:set_widget(indicator)

        self.lastpos = 1

				self.anim = animation:new({
					duration = 0.18,
					easing = animation.easing.linear,
					update = function(_, pos)
            bar.left  = 30 * (pos - 1)
            bar.right = (30*8) - (30 * (pos - 1))
					end,
				})

        local tb  = indicator.children[1]
        local num = tonumber(c3.name)
				if c3.selected then
          tb:set_markup_silently(colorize(c3.name, beautiful.fg))
          self.newpos  = num
          self.anim:set(num)
          self.lastpos = num
				elseif #c3:clients() == 0 then
          tb:set_markup_silently(colorize(c3.name, beautiful.wibar_empty))
				else
          tb:set_markup_silently(colorize(c3.name, beautiful.wibar_occupied))
        end
			end,

			update_callback = function(self, c3, _)
        local tb  = self.widget.children[1]
        local num = tonumber(c3.name)
			  if c3.selected then
          tb:set_markup_silently(colorize(c3.name, beautiful.fg))
          self.newpos  = num
          self.anim:set(num)
          self.lastpos = num
				elseif #c3:clients() == 0 then
          tb:set_markup_silently(colorize(c3.name, beautiful.wibar_empty))
				else
          tb:set_markup_silently(colorize(c3.name, beautiful.wibar_occupied))
				end
			end,
		},
		buttons = taglist_buttons,
	})

	return wibox.widget({
    {
      taglist,
      bar,
      spacing = dpi(3),
      layout  = wibox.layout.fixed.vertical,
    },
    top    = dpi(10),
    widget = wibox.container.margin,
	})

end
