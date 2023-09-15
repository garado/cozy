
-- █▄▀ █ ▀█▀ ▀█▀ █▄█    █▀ █▀▀ █▀ █▀ █ █▀█ █▄░█ 
-- █░█ █ ░█░ ░█░ ░█░    ▄█ ██▄ ▄█ ▄█ █ █▄█ █░▀█ 

-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ 
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local btn   = require("frontend.widget.button")
local awful = require("awful")
local wibox = require("wibox")
local kitty = require("backend.cozy.kitty")
local keynav = require("modules.keynav")
local strutil = require("utils.string")
local os = os

local HOME = os.getenv("HOME")
local SESSION_DIR = HOME .. "/.config/kitty/sessions"

local navigator, nav_root = keynav.navigator()

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀

local function gen_entry(name)
  return btn({
    text = name,
    bg = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
    on_release = function()
      local cmd = "kitty --session sessions/"..name
      awful.spawn.easy_async_with_shell(cmd, function() end)
      kitty:close()
    end
  })
end

local session_list = wibox.widget({
  ui.placeholder("No Kitty sessions configured..."),
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local content = wibox.widget({
  ui.textbox({
    text = "Session launcher",
    font = beautiful.font_med_m,
    align = "center",
  }),
  {
    session_list,
    widget = wibox.container.place,
  },
  spacing = dpi(12),
  layout = wibox.layout.fixed.vertical,
})

local launcher = awful.popup({
  type = "splash",
  minimum_width  = dpi(330),
  maximum_width  = dpi(330),
  shape = ui.rrect(),
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = wibox.widget({
    {
      content,
      margins = dpi(20),
      widget = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  }),
})


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

-- Populate session list
local cmd = "ls " .. SESSION_DIR
awful.spawn.easy_async_with_shell(cmd, function(stdout)
  local lines = strutil.split(stdout, "\r\n")
  if #lines == 0 then return end
  session_list:reset()
  for i = 1, #lines do
    local entry = gen_entry(lines[i])
    session_list:add(entry)
    nav_root:append(entry)
  end
end)

kitty:connect_signal("setstate::open", function()
  launcher.visible = true
  navigator:start()
end)

kitty:connect_signal("setstate::close", function()
  launcher.visible = false
  navigator:stop()
end)
