
-- █░░ █ █▄░█ █▄▀ █▀ 
-- █▄▄ █ █░▀█ █░█ ▄█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local widgets = require("ui.widgets")

local function create_link(args)
  local btn = widgets.button.text.normal ({
    text = args.name,
    text_normal_bg = beautiful.ctrl_link_fg,
    normal_bg = beautiful.ctrl_link_bg,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = args.func 
  })

  return wibox.widget({
    {
      btn,
      forced_width = dpi(200),
      widget = wibox.container.margin,
      -- need a cont here or else forced width
      -- will not work
    },
    widget = wibox.container.place,
  })
end

return wibox.widget({
  {
    create_link({
      name = "Email",
      func = function()
        awful.spawn("gio open https://mail.google.com/mail/u/0/#inbox") 
      end
    }),
    
    create_link({
      name = "UCSC Email",
      func = function()
        awful.spawn("gio open https://mail.google.com/mail/u/1/#inbox") 
      end
    }),
    
    create_link({
      name = "Canvas",
      func = function()
        awful.spawn("gio open https://canvas.ucsc.edu/")
      end
    }),

    create_link({
      name = "Awesome docs",
      func = function()
        awful.spawn("gio open https://awesomewm.org/apidoc/")
      end
    }),
    
    create_link({
      name = "ArchWiki",
      func = function()
        awful.spawn("gio open https://wiki.archlinux.org/")
      end
    }),

    create_link({
      name = "r/unixporn",
      func = function()
        awful.spawn("gio open https://www.reddit.com/r/unixporn")
      end
    }),

    spacing = dpi(5),
    forced_num_rows = 3,
    forced_num_cols = 2,
    layout = wibox.layout.grid,
  },
  widget = wibox.container.place,
})
