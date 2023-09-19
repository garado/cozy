
-- █▄▀ █▀▀ █▄█    ▄█▄    █▀▄▀█ █▀█ █░█ █▀ █▀▀    █▄▄ █ █▄░█ █▀▄ █▀ 
-- █░█ ██▄ ░█░    ░▀░    █░▀░█ █▄█ █▄█ ▄█ ██▄    █▄█ █ █░▀█ █▄▀ ▄█ 

-- For global keybinds:
-- Call the `gkbind` function.
--    gkbind(<keys>, <function>, <description>, <group>)

-- For client keybinds:
-- Same thing as global, but use `ckbind`.

-- Using keygroups:
-- Call `add_keygroup`. See the vimlike/workspace keygroups below.
--    add_keygroup(<kg_name>, <keys>)
-- Then when you want to use a keygroup:
--    gkbind("Shift+Alt+[<kg_name>]", ...)
-- i.e. gkbind("Shift+Alt+[vimlike]", ...)

local awful = require("awful")
local apps = require("sysconf.apps")

local binds = require("utils.binds")
local gkbind = binds.global_keybind
local ckbind = binds.client_keybind
local add_keygroup = binds.add_keygroup

add_keygroup("vimlike", { "h", "j", "k", "l" })
add_keygroup("workspace", { "1", "2", "3", "4", "5", "6", "7", "8" })


-- ▄▀█ █░█░█ █▀▄▀█ 
-- █▀█ ▀▄▀▄▀ █░▀░█ 

local help = require("frontend.help")

gkbind("Shift+Alt+r", awesome.restart, "restart", "AwesomeWM")
gkbind("Shift+Alt+q", awesome.quit, "quit", "AwesomeWM")
gkbind("Super+s", function() help:show_help() end, "show help", "AwesomeWM")


-- █░█ █▀█ ▀█▀ █▄▀ █▀▀ █▄█ █▀ 
-- █▀█ █▄█ ░█░ █░█ ██▄ ░█░ ▄█ 

-- Brightness
gkbind("XF86MonBrightnessUp", function()
  awful.spawn("brightnessctl set 5%+ -q", false)
  awesome.emit_signal("module::brightness")
end)

gkbind("XF86MonBrightnessDown", function()
  awful.spawn("brightnessctl set 5%- -q", false)
  awesome.emit_signal("module::brightness")
end)

-- Volume
gkbind("XF86AudioRaiseVolume", function()
  awful.spawn("pamixer -u ; pamixer -i 5", false)
  awesome.emit_signal("module::volume")
end)

gkbind("XF86AudioLowerVolume", function()
  awful.spawn("pamixer -u ; pamixer -d 5", false)
  awesome.emit_signal("module::volume")
end)

gkbind("XF86AudioMute", function()
  awful.spawn("pamixer -t", false)
  awesome.emit_signal("module::volume")
end)

-- Playerctl
gkbind("Super+XF86AudioLowerVolume", function()
  awful.spawn("playerctl play-pause", false)
end, "play/pause track", "Hotkeys")

gkbind("Super+XF86AudioLowerVolume", function()
  awful.spawn("playerctl previous")
end, "previous track", "Hotkeys")

gkbind("Super+XF86AudioRaiseVolume", function()
  awful.spawn("playerctl next")
end, "next track", "Hotkeys")

-- Picom killswitch
gkbind("Ctrl+Alt+p", function()
  local cmd = "pkill picom"
  awful.spawn.easy_async_with_shell(cmd, function() end)
end, "picom killswitch", "Hotkeys")

-- Dismiss notifications
gkbind("Super+n", function()
  require("naughty").destroy_all_notifications()
end, "dismiss notifs", "Hotkeys")

gkbind("Alt+s", function()
  require("backend.cozy.cozy"):emit_signal("systray::toggle")
end, "systray", "Launchers")

-- █░█░█ █▀█ █▀█ █▄▀ █▀ █▀█ ▄▀█ █▀▀ █▀▀ 
-- ▀▄▀▄▀ █▄█ █▀▄ █░█ ▄█ █▀▀ █▀█ █▄▄ ██▄ 

gkbind("Super+Tab", awful.tag.viewnext, "next workspace", "Workspace")
gkbind("Super+Shift+Tab", awful.tag.viewprev, "prev workspace", "Workspace")

gkbind("Super+[workspace]", function(i)
  local t = awful.screen.focused().tags[i]
  if t then t:view_only() end
end, "view nth workspace", "Workspace")

-- Move focused client to nth workspace
gkbind("Mod+Shift+[workspace]", function(i)
  if client.focus then
    local t = client.focus.screen.tags[i]
    if t then client.focus:move_to_tag(t) end
  end
end, "move client to workspace", "Workspace")


-- █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ █▀ 
-- █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ ▄█ 

local bec = require("backend.cozy")
gkbind("Alt+r",   function() bec.notrofi:toggle() end, "notrofi", "Launchers")
gkbind("Super+j", function() bec.dash:toggle() end, "dashboard", "Launchers")
gkbind("Super+o", function() bec.kitty:toggle() end, "kitty sessions", "Launchers")
gkbind("Super+k", function() bec.control:toggle() end, "control", "Launchers")
gkbind("Super+l", function() bec.themeswitch:toggle() end, "themes", "Launchers")

gkbind("Alt+Return", function()
  awful.spawn(apps.default.terminal)
end, "terminal", "Launchers")


-- █▀▀ █░░ █ █▀▀ █▄░█ ▀█▀ 
-- █▄▄ █▄▄ █ ██▄ █░▀█ ░█░ 

-- Toggle properties
ckbind("Ctrl+Shift+g", function(c) c.floating = not c.floating end, "floating", "Client")
ckbind("Ctrl+Shift+f", function(c) c.fullscreen = not c.fullscreen end, "fullscreen", "Client")
ckbind("Ctrl+Shift+d", function(c) c.sticky = not c.sticky end, "sticky", "Client")
ckbind("Ctrl+Shift+m", function(c) c.maximized = not c.maximized end,"min/maximize", "Client")
ckbind("Ctrl+Shift+w", function(c) c:kill() end,"close", "Client")

-- Saner keyboard resizing
local function resize_h(factor)
  local layout = awful.layout.get(awful.screen.focused())
  if layout == awful.layout.suit.tile then
    awful.tag.incmwfact(-factor)
  elseif layout == awful.layout.suit.tile.left then
    awful.tag.incmwfact(factor)
  elseif layout == awful.layout.suit.tile.top then
    awful.client.incwfact(-factor)
  elseif layout == awful.layout.suit.tile.bottom then
    awful.client.incwfact(-factor)
  end
end

local function resize_v(factor)
  local layout = awful.layout.get(awful.screen.focused())
  if layout == awful.layout.suit.tile then
    awful.client.incwfact(-factor)
  elseif layout == awful.layout.suit.tile.left then
    awful.client.incwfact(-factor)
  elseif layout == awful.layout.suit.tile.top then
    awful.tag.incmwfact(-factor)
  elseif layout == awful.layout.suit.tile.bottom then
    awful.tag.incmwfact(factor)
  end
end

ckbind("Alt+Shift+[vimlike]", function(i)
  local functions = { resize_h, resize_v, resize_v, resize_h }
  local factors = { 0.05, -0.05, 0.05, -0.05 }
  functions[i](factors[i])
end, "resize", "Client")

-- Swap clients
ckbind("Super+Shift+[vimlike]", function(i)
  local dir = { "left", "down", "up", "right" }
  awful.client.swap.bydirection(dir[i])
end, "swap", "Client")

-- Switch client focus
ckbind("Alt+Tab", function() awful.client.focus.byidx(1) end, "focus next", "Client")
ckbind("Alt+Shift+Tab", function() awful.client.focus.byidx(-1) end, "focus prev", "Client")

