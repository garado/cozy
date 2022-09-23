
-- █▀▄▀█ █░█ █▀ █ █▀▀   █▀█ █░░ ▄▀█ █▄█ █▀▀ █▀█ --
-- █░▀░█ █▄█ ▄█ █ █▄▄   █▀▀ █▄▄ █▀█ ░█░ ██▄ █▀▄ --
---------------- Credit: @rxyhn ------------------

local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local playerctl_daemon = require("signal.playerctl")

local music_text = wibox.widget({
  markup = helpers.ui.colorize_text("Music", beautiful.mus_playing_fg),
	font = beautiful.font_name .. "Medium 10",
  valign = "center",
  widget = wibox.widget.textbox,
})

local music_art = wibox.widget({
	image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.jpg",
	resize = true,
  horizontal_fit_policy = "expand",
  valign = "center",
  halign = "center",
	widget = wibox.widget.imagebox,
})

local music_art_container = wibox.widget({
	music_art,
	forced_height = dpi(120),
	forced_width = dpi(180),
	widget = wibox.container.background,
})

local filter_color = {
	type = "linear",
	from = { 0, 0 },
	to = { 0, 200 },
	stops = { { 0, beautiful.mus_filter_1}, { 1, beautiful.mus_filter_2 .. "cc" } },
}

local music_art_filter = wibox.widget({
	{
		bg = filter_color,
		forced_height = dpi(120),
		forced_width = dpi(200),
		widget = wibox.container.background,
	},
	direction = "east",
	widget = wibox.container.rotate,
})

local music_title = wibox.widget({
  markup = helpers.ui.colorize_text("Nothing playing", beautiful.mus_playing_fg),
	font = beautiful.font_name .. "Regular 13",
	valign = "center",
	widget = wibox.widget.textbox,
})

local music_artist = wibox.widget({
  markup = helpers.ui.colorize_text("Nothing playing", beautiful.mus_playing_fg),
	font = beautiful.font_name .. "Bold 16",
	valign = "center",
	widget = wibox.widget.textbox,
})

local playerctl_buttons = {
  {
	  widgets.playerctl.previous(20, beautiful.mus_control_fg, beautiful.mus_control_bg),
	  widgets.playerctl.play(beautiful.mus_control_fg, beautiful.mus_control_bg),
	  widgets.playerctl.next(20, beautiful.mus_control_fg, beautiful.mus_control_bg),
	  layout = wibox.layout.flex.horizontal,
  },
	forced_height = dpi(70),
	margins = dpi(10),
	widget = wibox.container.margin,
}

local artist_scrollbox = wibox.widget({
  music_artist,
  fps = 60,
  speed = 75,
  step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
  widget = wibox.container.scroll.horizontal,
})

local title_scrollbox = wibox.widget({
   music_title,
   fps = 60,
   speed = 75,
   step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
   widget = wibox.container.scroll.horizontal,
})

local music = wibox.widget({
	{
		{
			{
				music_art_container,
				music_art_filter,
				layout = wibox.layout.stack,
			},
			{
				{
					{
						music_text,
						helpers.ui.vertical_pad(dpi(15)),
						{
              artist_scrollbox,
              title_scrollbox,
							forced_width = dpi(170),
							layout = wibox.layout.fixed.vertical,
						},
						layout = wibox.layout.fixed.vertical,
					},
					nil,
          playerctl_buttons,
					expand = "none",
					layout = wibox.layout.align.vertical,
				},
				top = dpi(9),
				bottom = dpi(9),
				left = dpi(10),
				right = dpi(10),
				widget = wibox.container.margin,
			},
			layout = wibox.layout.stack,
		},
    bg = beautiful.mus_bg,
		shape = helpers.ui.rrect(beautiful.border_radius),
		forced_width = dpi(200),
		forced_height = dpi(200),
		widget = wibox.container.background,
	},
	margins = dpi(10),
	color = "#FF000000",
	widget = wibox.container.margin,
})

--- playerctl
--- -------------
playerctl_daemon:connect_signal("metadata", function(_, title, artist, album_path, _, _, _)
	if title == "" then
		title = "Nothing playing"
	end
	if artist == "" then
		artist = "Nothing playing"
	end
	if album_path == "" then
		album_path = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.jpg"
    music_art.resize = true
    music_art.horizontal_fit_policy = "expand"
  else
    music_art.resize = false
    music_art.horizontal_fit_policy = "none"
  end

	music_art:set_image(gears.surface.load_uncached(album_path))
	music_title:set_markup_silently(helpers.ui.colorize_text(title, beautiful.mus_control_fg))
	music_artist:set_markup_silently(helpers.ui.colorize_text(artist, beautiful.mus_control_fg))
end)

playerctl_daemon:connect_signal("playback_status", function(_, playing, _)
	if playing then
		music_text:set_markup_silently(helpers.ui.colorize_text("Now playing", beautiful.mus_playing_fg))
	else
		music_text:set_markup_silently(helpers.ui.colorize_text("Music", beautiful.mus_playing_fg))
	end
end)

return music
