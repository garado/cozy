
-- █▄▀ █▀▀ █▄█ █▀
-- █░█ ██▄ ░█░ ▄█

local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local apps = require("configuration.apps")
local bling = require("modules.bling")
local naughty = require("naughty")
local os = os

local dash = require("core.cozy.dash")
local control = require("core.cozy.control")
local themeswitcher = require("core.cozy.themeswitcher")

local mod   = "Mod4"
local alt   = "Mod1"
local ctrl  = "Control"
local shift = "Shift"

-- Sane(er) keyboard resizing
local function resize_horizontal(factor) local layout = awful.layout.get(awful.screen.focused())
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

local function resize_vertical(factor)
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

-- check if currently focused client is master
local function focused_is_master()
  local master = awful.client.getmaster()
  local focused = awful.client.focus
  local nmaster = math.min(t.master_count, #p.clients)
  for i = 1, nmaster do
    require("naughty").notification { message = "master selected" }
  end
end

local scratchpad = bling.module.scratchpad {
  command = "kitty --class spad --session sessions/scratchpad",
  rule = { instance = "spad" },
  sticky = true,
  autoclose = true,
  floating = true,
  geometry = {x=360, y=90, height=900, width=1200},
  reapply = true,
  dont_focus_before_close = true,
}

awesome.connect_signal("startup", function()
  scratchpad:turn_off()
end)


-- ░█▀▀░█░░░█▀█░█▀▄░█▀█░█░░░░░█░█░█▀▀░█░█░█▀▄░▀█▀░█▀█░█▀▄░█▀▀
-- ░█░█░█░░░█░█░█▀▄░█▀█░█░░░░░█▀▄░█▀▀░░█░░█▀▄░░█░░█░█░█░█░▀▀█
-- ░▀▀▀░▀▀▀░▀▀▀░▀▀░░▀░▀░▀▀▀░░░▀░▀░▀▀▀░░▀░░▀▀░░▀▀▀░▀░▀░▀▀░░▀▀▀
awful.keyboard.append_global_keybindings({

  -- ▄▀█ █░█░█ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀
  -- █▀█ ▀▄▀▄▀ ██▄ ▄█ █▄█ █░▀░█ ██▄
  -- Restart awesome
  awful.key({ mod, ctrl }, "r", awesome.restart,
    { description = "reload", group = "Awesome" }),

  -- Quit awesome
  awful.key({ mod, ctrl }, "q", awesome.quit,
    { description = "quit", group = "Awesome" }),

  -- Show help
  awful.key({ mod }, "F1", hotkeys_popup.show_help,
    { description = "help", group = "Awesome"}),

  -- Daily briefing
  awful.key({ mod }, "d", function()
    scratchpad:turn_off()
    awesome.emit_signal("daily_briefing::toggle", s)
  end, { description = "daily briefing", group = "Awesome" }),

  -- Toggle dash
  awful.key({ mod, shift }, "d", function()
    scratchpad:turn_off()
    dash:toggle()
  end, { description = "dash", group = "Awesome" }),

  -- Toggle control center
  awful.key({ mod }, "c", function()
    scratchpad:turn_off()
    control:toggle()
  end, { description = "control center", group = "Awesome" }),

  -- Toggle theme switcher
  awful.key({ mod }, "s", function()
    scratchpad:turn_off()
    themeswitcher:toggle()
  end, { description = "dash", group = "Awesome" }),

  -- Toggle layout list switcher
  awful.key({ mod, shift }, "u", function()
    scratchpad:turn_off()
    awesome.emit_signal("layoutlist::toggle")
  end, { description = "layout list", group = "Awesome"}),


  -- █░█ █▀█ ▀█▀ █▄▀ █▀▀ █▄█ █▀
  -- █▀█ █▄█ ░█░ █░█ ██▄ ░█░ ▄█
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
  awful.key({ mod }, "XF86AudioLowerVolume", function()
    awful.spawn("playerctl play-pause", false)
  end, { description = "play/pause track", group = "Hotkeys" }),

  awful.key({ mod }, "XF86AudioMute", function()
    awful.spawn("playerctl previous", false)
  end, { description = "previous track", group = "Hotkeys" }),

  awful.key({ mod }, "XF86AudioRaiseVolume", function()
    awful.spawn("playerctl next", false)
  end, { description = "next track", group = "Hotkeys" }),

  -- Screenshot of entire screen
  awful.key({ mod, shift }, "s", function()
    local home = os.getenv("HOME")
    local cmd = "scrot " .. home  .. "/Pictures/Screenshots/%b%d::%H%M%S.png --silent -s -e 'xclip -selection clipboard -t image/png -i $f'"
    awful.spawn.easy_async(cmd, function() end)
  end, { description = "screenshot (select)", group = "Hotkeys" }),

  -- Screenshot and select region
  awful.key({ mod, alt }, "s", function()
    local home = os.getenv("HOME")
    local cmd = "scrot " .. home  .. "/Pictures/Screenshots/%b%d::%H%M%S.png --silent 'xclip -selection clipboard -t image/png -i $f'"
    awful.spawn.easy_async(cmd, function() end)
  end, { description = "screenshot (whole screen)", group = "Hotkeys" }),

  -- Dismiss notifications
  awful.key({ mod }, "n", function()
    naughty.destroy_all_notifications()
  end, { description = "dismiss notifications", group = "Hotkeys" }),

  --  █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ █▀
  --  █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ ▄█
  -- Terminal
  awful.key({ mod }, "Return", function()
    awful.spawn(apps.default.terminal)
  end, { description = "terminal", group = "Launchers" }),
  
  -- Floating Terminal
  awful.key({ mod, shift }, "Return", function()
    awful.spawn(apps.default.terminal, {
      floating=true,
      tag = mouse.screen.selected_tag,
      placement = awful.placement.center
    })
  end, { description = "terminal", group = "Launchers" }),

  -- Rofi app launcher
  awful.key({ mod }, "r", function()
    awful.spawn(apps.utils.app_launcher)
  end, { description = "app launcher", group = "Launchers" }),

  -- Web browser
  awful.key({ mod} , "w", function()
    awful.spawn(apps.default.web_browser)
  end, { description = "web browser", group ="Launchers"}),
  --
  -- file browser
  awful.key({ mod } , "f", function()
    awful.spawn(apps.default.file_manager)
  end, { description = "file browser", group ="Launchers"}),

  -- Bluetooth menu
  awful.key({ alt }, "b", function()
    awful.spawn(apps.utils.bluetooth)
  end, { description = "bluetooth", group = "Launchers" }),
})


-- ░█▀▀░█░░░▀█▀░█▀▀░█▀█░▀█▀░░░█░█░█▀▀░█░█░█▀▄░▀█▀░█▀█░█▀▄░█▀▀
-- ░█░░░█░░░░█░░█▀▀░█░█░░█░░░░█▀▄░█▀▀░░█░░█▀▄░░█░░█░█░█░█░▀▀█
-- ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░░▀░░░░▀░▀░▀▀▀░░▀░░▀▀░░▀▀▀░▀░▀░▀▀░░▀▀▀
client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    -- Focus client by direction
    -- Focus Up
    awful.key({ mod }, "k", function()
      awful.client.focus.bydirection("up")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus up", group = "Client" }),

    -- Focus Down
    awful.key({ mod }, "j", function()
      awful.client.focus.bydirection("down")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus down", group = "Client" }),

    -- Focus Left
    awful.key({ mod }, "h", function()
      awful.client.focus.bydirection("left")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus left", group = "Client" }),

    -- Focus right
    awful.key({ mod }, "l", function()
      awful.client.focus.bydirection("right")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus right", group = "Client" }),
  -- 
  -- Focus by direction keys
    awful.key({ mod }, "Up", function()
      awful.client.focus.bydirection("up")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus up", group = "Client" }),
    awful.key({ mod }, "Down", function()
      awful.client.focus.bydirection("down")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus down", group = "Client" }),
    awful.key({ mod }, "Left", function()
      awful.client.focus.bydirection("left")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus left", group = "Client" }),
    awful.key({ mod }, "Right", function()
      awful.client.focus.bydirection("right")
      bling.module.flash_focus.flashfocus(client.focus)
    end, { description = "focus right", group = "Client" }),
  --


  -- Window layout keys
    -- Toggle floating
    awful.key({ mod, shift }, "t", function()
      client.focus.floating = not client.focus.floating
      client.focus:raise()
    end, { description = "floating", group = "Client" }),

    -- Toggle fullscreen
    awful.key({ mod, shift }, "f", function()
      client.focus.fullscreen = not client.focus.fullscreen
      client.focus:raise()
    end, { description = "fullscreen", group = "Client" }),

    -- Toggle sticky
    awful.key({ mod, shift }, "a", function()
      client.focus.sticky = not client.focus.sticky
    end, { description = "sticky", group = "Client" }),

    -- MAXIMIZE KEYS
    -- Toggle Maximize
    awful.key({ mod }, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = "(un)maximize", group = "Client" }),
    -- Toggle maximize vertical
    awful.key({ mod, ctrl }, "m", function(c)
      c.maximized_vertical = not c.maximized_vertical
      c:raise()
    end, { description = "(un) maximize vertically", group = "Client"}),
    -- Toggle maximize horizontal
    awful.key({ mod, shift }, "m", function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c:raise()
		end, { description = "(un)maximize horizontally", group = "Client" }),


    -- Close window
    awful.key({ mod, shift }, "c", function()
      client.focus:kill()
    end, { description = "close", group = "Client" }),

    -- Layout-aware resizing
    awful.key({ mod, ctrl }, "h", function () resize_horizontal(0.05) end,
    { group = "Client", description = "(right) resize" }),
    awful.key({ mod, ctrl   }, "l", function () resize_horizontal(-0.05) end, 
      { group = "Client", description = "(left) resize"}),
    awful.key({ mod, ctrl   }, "k", function () resize_vertical(-0.05) end,
      { group = "Client", description = "(up) resize"}),
    awful.key({ mod, ctrl   }, "j", function () resize_vertical(0.05) end,
      { group = "Client", description = "(down) resize"}),

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
  awful.key({ mod, shift }, "h", function()
    awful.client.swap.global_bydirection("left")
  end, { description = "(v) swap left", group = "Client"}),

  awful.key({ mod, shift }, "j", function()
    awful.client.swap.global_bydirection("down")
  end),

  awful.key({ mod, shift }, "k", function()
    awful.client.swap.global_bydirection("up")
  end),

  awful.key({ mod, shift }, "l", function()
    awful.client.swap.global_bydirection("right")
  end),

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
    keygroup = "numrow",
    description = "view nth workspace",
    group = "Workspace",
    on_press = function(index)
      local screen = awful.screen.focused()
      local tag = screen.tags[index]
      if tag then
        tag:view_only()
      end
    end,
  }),

  -- Move focused client to workspace
  awful.key({
    modifiers = { mod, shift },
    keygroup = "numrow",
    description = "move focused client to workspace",
    group = "Workspace",
    on_press = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  }),

  awful.key({ mod, alt }, "Tab", function()
    if client.focus then
        client.focus:move_to_screen()
    end
  end,{ description="Move focused client to next screen", group="Client"}),

  awful.key({
    modifiers = { mod, alt },
    keygroup = "numrow",
    description = "move focused client to workspace next screen",
    group = "Workspace",
    on_press = function(index)
      if client.focus then
        client.focus:move_to_screen()
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
          tag:view_only()
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

-- Screen
-----------
awful.keyboard.append_global_keybindings({
-- No need for these (single screen setup)
awful.key({ mod, ctrl, alt }, "j", function () awful.screen.focus_relative(1) end,
  {description = "focus the next screen", group = "screen"}),
awful.key({ mod, ctrl, alt }, "k", function () awful.screen.focus_relative(-1) end,
  {description = "focus the previous screen", group = "screen"}),
})
