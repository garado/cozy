
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui = require("utils.ui")
local dpi = ui.dpi
local beautiful = require("beautiful")

local FG_EMPTY    = beautiful.neutral[600]
local FG_FOCUSED  = beautiful.primary[400]
local FG_OCCUPIED = beautiful.neutral[100]

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
      tb:update_text(c3.name)
      tb:update_color(FG_FOCUSED)
    elseif #c3:clients() == 0 then
      tb:update_text(c3.name)
      tb:update_color(FG_EMPTY)
    else
      tb:update_text(c3.name)
      tb:update_color(FG_OCCUPIED)
    end
  end

  local function create_callback(self, c3, _)
  	local indicator = wibox.widget({
      ui.textbox({
        text  = "-",
        align = "center",
        font  = beautiful.font_reg_xs,
      }),
  		valign = "center",
  		widget = wibox.container.place,
  	})
		self:set_widget(indicator)
    update_callback(self, c3, _)
  end

	local taglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = wibox.layout.fixed.horizontal,
		widget_template = {
      create_callback = create_callback,
			update_callback = update_callback,
			forced_width  = dpi(25),
			forced_height = dpi(30),
			widget = wibox.container.margin,
		},
    buttons = taglist_buttons,
	})

	return wibox.widget({
		taglist,
		margins = dpi(8),
		widget  = wibox.container.margin,
	})
end
