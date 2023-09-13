
-- █░█ █▀█ ▀█▀ █▄▀ █▀▀ █▄█ █▀ 
-- █▀█ █▄█ ░█░ █░█ ██▄ ░█░ ▄█ 

local awful   = require("awful")
local apps    = require("sysconf.apps")
local naughty = require("naughty")
local bling   = require("modules.bling")
local os = os

local control = require("backend.cozy.control")
local dash  = require("backend.cozy.dash")
local cozy  = require("backend.cozy.cozy")
local themeswitch = require("backend.cozy.themeswitch")
local nrofi = require("backend.cozy.notrofi")
local bluetooth = require("backend.cozy.bluetooth")
local help = require("frontend.help")
local kitty = require("backend.cozy.kitty")

local mod   = "Mod4"
local alt   = "Mod1"
local ctrl  = "Control"
local shift = "Shift"

awful.key.keygroups["workspaces"] = {
  { "1", 1 },
  { "2", 2 },
  { "3", 3 },
  { "4", 4 },
  { "5", 5 },
  { "6", 6 },
  { "7", 7 },
  { "8", 8 },
}

awful.key.keygroups["vimlike"] = {
  { "h", 1 },
  { "j", 2 },
  { "k", 3 },
  { "l", 4 },
}

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
  elseif layout == bling.layout.mstab then
    awful.tag.incmwfact(factor)
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

local scratchpad = bling.module.scratchpad {
  command = "kitty --class spad --instance-group scratch --session sessions/scratchpad",
  rule = { instance = "spad" },
  sticky = true,
  autoclose = true,
  floating = true,
  geometry = { x=360, y=90, height=900, width=1200 },
  reapply = true,
  dont_focus_before_close = true,
}


-- ░█▀▀░█░░░█▀█░█▀▄░█▀█░█░░░░░█░█░█▀▀░█░█░█▀▄░▀█▀░█▀█░█▀▄░█▀▀
-- ░█░█░█░░░█░█░█▀▄░█▀█░█░░░░░█▀▄░█▀▀░░█░░█▀▄░░█░░█░█░█░█░▀▀█
-- ░▀▀▀░▀▀▀░▀▀▀░▀▀░░▀░▀░▀▀▀░░░▀░▀░▀▀▀░░▀░░▀▀░░▀▀▀░▀░▀░▀▀░░▀▀▀

awful.keyboard.append_global_keybindings({

  -- ▄▀█ █░█░█ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀
  -- █▀█ ▀▄▀▄▀ ██▄ ▄█ █▄█ █░▀░█ ██▄

  -- Restart
  awful.key({ shift, alt }, "r", awesome.restart,
    { description = "reload", group = "Awesome" }),

  -- Quit
  awful.key({ shift, alt }, "q", awesome.quit,
    { description = "quit", group = "Awesome" }),

  -- Show
  awful.key({ mod }, "s", function()
    cozy:close_all()
    help:show_help()
  end, { description = "show help", group = "Awesome"}),


  -- █░█ █▀█ ▀█▀ █▄▀ █▀▀ █▄█ █▀
  -- █▀█ █▄█ ░█░ █░█ ██▄ ░█░ ▄█

  -- Picom killswitch
  awful.key({ ctrl, alt }, "p", function()
    local cmd = "pkill picom"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end, { description = "picom killswitch", group = "Hotkeys" }),

  -- Adjust brightness
  awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn("brightnessctl set 5%+ -q", false)
    awesome.emit_signal("module::brightness")
  end),

  awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn("brightnessctl set 5%- -q", false)
    awesome.emit_signal("module::brightness")
  end),

  --- Audio control
  awful.key({}, "XF86AudioRaiseVolume", function()
    awful.spawn("pamixer -u ; pamixer -i 5", false)
    awesome.emit_signal("module::volume")
  end),

  awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn("pamixer -u ; pamixer -d 5", false)
    awesome.emit_signal("module::volume")
  end),

  awful.key({}, "XF86AudioMute", function()
    awful.spawn("pamixer -t", false)
    awesome.emit_signal("module::volume")
  end),

  -- Playerctl
  awful.key({}, "XF86AudioPlay", function()
    awful.spawn("playerctl play-pause", false)
  end),

  awful.key({ mod }, "XF86AudioLowerVolume", function()
    awful.spawn("playerctl play-pause", false)
  end, { description = "play/pause track", group = "Hotkeys" }),

  awful.key({}, "XF86AudioPrev", function()
    awful.spawn("playerctl previous", false)
  end),

  awful.key({ mod }, "XF86AudioMute", function()
    awful.spawn("playerctl previous", false)
  end, { description = "previous track", group = "Hotkeys" }),

  awful.key({}, "XF86AudioNext", function()
    awful.spawn("playerctl next", false)
  end),

  awful.key({ mod }, "XF86AudioRaiseVolume", function()
    awful.spawn("playerctl next", false)
  end, { description = "next track", group = "Hotkeys" }),

  -- TODO replace with awful screenshot
  -- Screenshot of entire screen
  awful.key({ mod, shift }, "s", function()
    local home = os.getenv("HOME")
    local cmd = "scrot " .. home  .. "/Pictures/Screenshots/%b%d::%H%M%S.png --silent -s -e 'xclip -selection clipboard -t image/png -i $f'"
    awful.spawn.easy_async(cmd, function() end)
  end, { description = "screenshot (select)", group = "Hotkeys" }),

  -- Screenshot and select region
  -- TODO: Use awful.screenshot instead
  awful.key({ mod, alt }, "s", function()
    local home = os.getenv("HOME")
    local cmd = "scrot " .. home  .. "/Pictures/Screenshots/%b%d::%H%M%S.png --silent 'xclip -selection clipboard -t image/png -i $f'"
    awful.spawn.easy_async(cmd, function() end)
  end, { description = "screenshot (screen)", group = "Hotkeys" }),

  -- Dismiss notifications
  awful.key({ mod }, "n", function()
    naughty.destroy_all_notifications()
  end, { description = "dismiss notifications", group = "Hotkeys" }),


  -- █▀▀ █▀█ ▀█ █▄█
  -- █▄▄ █▄█ █▄ ░█░

  awful.key({ mod }, "j", function()
    scratchpad:turn_off()
    dash:toggle()
  end, { description = "dashboard", group = "Launchers" }),

  awful.key({ mod }, "k", function()
    scratchpad:turn_off()
    control:toggle()
  end, { description = "control center", group = "Launchers "}),

  awful.key({ mod }, "l", function()
    scratchpad:turn_off()
    themeswitch:toggle()
  end, { description = "theme switcher", group = "Launchers "}),

  awful.key({ alt }, "b", function()
    scratchpad:turn_off()
    bluetooth:toggle()
  end, { description = "bluetooth menu", group = "Launchers "}),

  awful.key({ alt }, "r", function()
    scratchpad:turn_off()
    nrofi:toggle()
  end, { description = "not rofi", group = "Launchers" }),

  awful.key({ mod }, "o", function()
    scratchpad:turn_off()
    kitty:toggle()
  end, { description = "kitty sessions", group = "Launchers "}),

  --  █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ █▀
  --  █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ ▄█

  -- Terminal
  awful.key({ alt }, "Return", function()
    awful.spawn(apps.default.terminal)
  end, { description = "terminal", group = "Launchers" }),

  -- Toggle scratchpad
  awful.key({ mod }, "p", function()
    cozy:close_all()
    scratchpad:toggle()
  end, { description = "scratchpad", group = "Launchers"}),

  -- Thunar
  awful.key({ alt }, "t", function()
    awful.spawn(apps.default.file_manager)
  end, { description = "file manager", group = "Launchers" }),

  -- -- Bluetooth menu
  -- awful.key({ alt }, "b", function()
  --   awful.spawn(apps.utils.bluetooth)
  -- end, { description = "bluetooth", group = "Launchers" }),
})


-- █▀▀ █░░ █ █▀▀ █▄░█ ▀█▀
-- █▄▄ █▄▄ █ ██▄ █░▀█ ░█░

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({

    -- Toggle floating
    awful.key({ ctrl, shift }, "g", function()
      client.focus.floating = not client.focus.floating
      client.focus:raise()
    end, { description = "toggle floating", group = "Client" }),

    -- Toggle fullscreen
    awful.key({ ctrl, shift }, "f", function()
      client.focus.fullscreen = not client.focus.fullscreen
      client.focus:raise()
    end, { description = "toggle fullscreen", group = "Client" }),

    -- Toggle sticky
    awful.key({ ctrl, shift }, "d", function()
      client.focus.sticky = not client.focus.sticky
    end, { description = "toggle sticky", group = "Client" }),

    -- Toggle maximize
    awful.key({ ctrl, shift }, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = "toggle min/maximize", group = "Client" }),

    -- Close window
    awful.key({ ctrl, shift }, "w", function()
      client.focus:kill()
    end, { description = "close", group = "Client" }),

    -- Layout-aware resizing
    awful.key({
      modifiers = { alt, shift },
      keygroup = "vimlike",
      description = "resize",
      group = "Client",
      on_press = function(index)
        local functions = { resize_h, resize_v, resize_v, resize_h }
        local factors = { 0.05, -0.05, 0.05, -0.05 }
        functions[index](factors[index])
      end,
    }),

    -- Changing focus
    -- Special case: mstab layout (TODO)
    awful.key({ alt }, "Tab", function()
      local layout = awful.layout.get(awful.screen.focused())
      if layout.name == "mstab" then
        -- if a slave is selected, alt tab switches between master and slave
        awful.client.focus.byidx(1)
      else
        awful.client.focus.byidx(1)
      end
    end),

    awful.key({ alt , shift }, "Tab", function()
      awful.client.focus.byidx(-1)
    end),

    -- When in mstab, ctrl tab cycles between only slaves
    -- If master selected and ctrl tab is pressed, go to slave
    -- awful.key({ ctrl }, "Tab", function()
    -- end),

    -- Swapping clients
    awful.key({
      modifiers = { mod, shift },
      keygroup = "vimlike",
      description = "swap",
      group = "Client",
      on_press = function(index)
        local dir = { "left", "down", "up", "right" }
        awful.client.swap.bydirection(dir[index])
      end,
    }),

  })
end)


-- ░█░█░█▀█░█▀▄░█░█░█▀▀░█▀█░█▀█░█▀▀░█▀▀░░░█░█░█▀▀░█░█░█▀▄░▀█▀░█▀█░█▀▄░█▀▀
-- ░█▄█░█░█░█▀▄░█▀▄░▀▀█░█▀▀░█▀█░█░░░█▀▀░░░█▀▄░█▀▀░░█░░█▀▄░░█░░█░█░█░█░▀▀█
-- ░▀░▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░░░▀░▀░▀▀▀░▀▀▀░░░▀░▀░▀▀▀░░▀░░▀▀░░▀▀▀░▀░▀░▀▀░░▀▀▀

awful.keyboard.append_global_keybindings({
  -- Switch to prev/next workspaces 
  awful.key({ mod }, "Tab", awful.tag.viewnext,
    {description = "view next workspace", group = "Workspace" }),
  awful.key({ mod, shift }, "Tab", awful.tag.viewprev,
    {description = "view previous workspace", group = "Workspace" }),

  -- View nth workspace
  awful.key({
    modifiers = { mod },
    keygroup = "workspaces",
    description = "view nth workspace",
    group = "Workspace",
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then tag:view_only() end
    end,
  }),

  -- Move focused client to workspace
  awful.key({
    modifiers = { mod, shift },
    keygroup = "numrow",
    -- description = "move focused client to workspace",
    group = "Workspace",
    on_press = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  })
})

client.connect_signal("request::default_mousebindings", function()
  awful.mouse.append_client_mousebindings({
    awful.button({ }, 1, function (c)
      c:activate { context = "mouse_click" }
    end),
    awful.button({ mod }, 1, function (c)
      c:activate { context = "mouse_click", action = "mouse_move"  }
    end),
    awful.button({ mod }, 3, function (c)
      c:activate { context = "mouse_click", action = "mouse_resize"}
    end),
  })
end)

