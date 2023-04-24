
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("utils.ui").dpi
local colorize    = require("utils.ui").colorize
local beautiful   = require("beautiful")

return function(s)
  -- Mouse + client actions
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

  local function update_callback(self, c3, _)
    local tb = self.widget.children[1]
    if c3.selected then
      tb:set_markup_silently(colorize(c3.name, beautiful.wibar_focused))
    elseif #c3:clients() == 0 then
      tb:set_markup_silently(colorize(c3.name, beautiful.wibar_empty))
    else
      tb:set_markup_silently(colorize(c3.name, beautiful.wibar_occupied))
    end
  end

	local taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = { layout = wibox.layout.fixed.vertical },
		widget_template = {
			widget = wibox.container.margin,
			forced_width  = dpi(15),
			forced_height = dpi(30),
			create_callback = function(self, c3, _)
				local indicator = wibox.widget({
					{
            markup = colorize("-", beautiful.fg_0),
            font   = beautiful.font_reg_xs,
            align  = "center",
            valign = "center",
            widget = wibox.widget.textbox,
					},
					valign = "center",
					widget = wibox.container.place,
				})
				self:set_widget(indicator)
        update_callback(self, c3, _)
			end,
			update_callback = update_callback,
		},
		buttons = taglist_buttons,
	})

	return wibox.widget({
		taglist,
		margins = dpi(8),
		widget = wibox.container.margin,
	})
end
