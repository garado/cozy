
-- █▀▄▀█ █░█ █▀ █ █▀▀   █▀█ █░░ ▄▀█ █▄█ █▀▀ █▀█ --
-- █░▀░█ █▄█ ▄█ █ █▄▄   █▀▀ █▄▄ █▀█ ░█░ ██▄ █▀▄ --

-- Credit: @rxyhn

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local playerctl_daemon = require("backend.system.playerctl")


-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

local metadata_status = ui.textbox({
  text = "Music",
  font = beautiful.font_med_s,
  height = dpi(18),
})

local metadata_title = ui.textbox({
  text = "Nothing playing",
  font = beautiful.font_bold_l,
})

local metadata_artist = ui.textbox({
  text = "Nothing playing",
  font = beautiful.font_reg_m,
})

local metadata_art = wibox.widget({
  image = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png",
  horizontal_fit_policy = "expand",
  resize = true,
  valign = "center",
  halign = "center",
  widget = wibox.widget.imagebox,
})

local album_art_filter = wibox.widget({
  {
    bg = {
      type  = "linear",
      from  = { 0, 0 },
      to    = { 0, 400 },
      stops = { { 0, beautiful.primary[800]}, { 1, beautiful.primary[700] .. "99" } },
    },
    widget = wibox.container.background,
  },
  direction = "east",
  widget = wibox.container.rotate,
})

awesome.connect_signal("theme::reload", function(lut)
  album_art_filter.widget.bg = {
    type  = "linear",
    from  = { 0, 0 },
    to    = { 0, 400 },
    stops = { { 0, beautiful.primary[800]}, { 1, beautiful.primary[700] .. "99" } },
  }
end)

-- local playerctl_buttons = {
--   {
-- 	  widgets.playerctl.previous(20, beautiful.mus_control_fg, beautiful.mus_control_bg),
-- 	  widgets.playerctl.play(beautiful.mus_control_fg, beautiful.mus_control_bg),
-- 	  widgets.playerctl.next(20, beautiful.mus_control_fg, beautiful.mus_control_bg),
-- 	  layout = wibox.layout.flex.horizontal,
--   },
-- 	forced_height = dpi(70),
-- 	margins = dpi(10),
-- 	widget = wibox.container.margin,
-- }

local artist_scrollbox = wibox.widget({
  metadata_artist,
  fps = 60,
  speed = 75,
  step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
  widget = wibox.container.scroll.horizontal,
})

local title_scrollbox = wibox.widget({
  metadata_title,
  fps = 60,
  speed = 75,
  step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
  widget = wibox.container.scroll.horizontal,
})

local music = wibox.widget({
  {
    {
      metadata_art,
      album_art_filter,
      layout = wibox.layout.stack,
    },
    {
      {
        {
          metadata_status,
          ui.vpad(dpi(15)),
          {
            title_scrollbox,
            artist_scrollbox,
            forced_width = dpi(170),
            spacing = dpi(5),
            layout = wibox.layout.fixed.vertical,
          },
          layout = wibox.layout.fixed.vertical,
        },
        nil,
        -- playerctl_buttons,
        expand = "none",
        layout = wibox.layout.align.vertical,
      },
      margins = dpi(22),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  },
  bg = beautiful.neutral[800],
  shape  = ui.rrect(),
  widget = wibox.container.background,
})


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

playerctl_daemon:connect_signal("metadata", function(_, title, artist, album_path, _, _, _)
  if title == "" then
    title = "Nothing playing"
  end

  if artist == "" then
    artist = "Nothing playing"
  end

  if album_path == "" then
    album_path = gears.filesystem.get_configuration_dir() .. "theme/assets/no_music.png"
    metadata_art.resize = true
    metadata_art.horizontal_fit_policy = "expand"
  else
    metadata_art.resize = false
    metadata_art.horizontal_fit_policy = "none"
  end

  metadata_art:set_image(gears.surface.load_uncached(album_path))
  metadata_title:set_markup_silently(ui.colorize(title, beautiful.mus_control_fg))
  metadata_artist:set_markup_silently(ui.colorize(artist, beautiful.mus_control_fg))
end)

playerctl_daemon:connect_signal("playback_status", function(_, playing, src)
  local icon = ""
  if src == "ncspot" or src == "spotify" then
    icon = ""
  elseif src == "firefox" then
    icon = ""
  end

  if playing then
    metadata_status:set_markup_silently(ui.colorize(icon .. " Now playing"))
  else
    metadata_status:set_markup_silently(ui.colorize("Paused"))
  end
end)

return music

-- return wibox.widget({
--   music,
--   content_fill_horizontal = true,
--   content_fill_vertical = true,
--   widget = wibox.container.place,
-- })
