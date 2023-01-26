
-- █░░ █ █▄░█ █▄▀ █▀ 
-- █▄▄ █ █░▀█ █░█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")
local Area = require("modules.keynav.area")
local Elevated = require("modules.keynav.navitem").Elevated

local nav_links = Area:new({ name = "links" })

local function create_link(args)
  local btn = widgets.button.text.normal ({
    text = args.name,
    text_normal_bg = beautiful.ctrl_link_fg,
    normal_bg = beautiful.ctrl_link_bg,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      args.func()
      awesome.emit_signal("control_center::toggle")
    end
  })

  nav_links:append(Elevated:new(btn))

  return wibox.widget({
    {
      btn,
      forced_width = dpi(200),
      widget = wibox.container.margin,
      -- need a container here or forced_width won't work
    },
    widget = wibox.container.place,
  })
end

local widget = wibox.widget({
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
      name = "Lua manual",
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

local cont = wibox.widget({
  {
    text = "LINKS",
    align = "center",
    valign = "center",
    font = beautiful.font_name .. "10",
    widget = wibox.widget.textbox,
  },
  widget,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

return function()
  return nav_links, cont
end
