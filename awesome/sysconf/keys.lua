
-- █▄▀ █▀▀ █▄█ █▀
-- █░█ ██▄ ░█░ ▄█

-- Keybindings

local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local awful   = require("awful")
local apps    = require("sysconf.apps")
local naughty = require("naughty")
local bling   = require("modules.bling")
local rrect   = require("utils.ui").rrect
local dpi     = require("utils.ui").dpi
local os = os

local cozy  = require("backend.state.cozy")
local dash  = require("backend.state.dash")

local mod   = "Mod4"
local alt   = "Mod1"
local ctrl  = "Control"
local shift = "Shift"

-- Saner keyboard resizing
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

local app_launcher = bling.widget.app_launcher({
  terminal = "kitty",
  favorites = { "firefox", },
  search_commands = true,
  skip_commands = { "thunar" },
  hide_on_right_clicked_outside = true,
  hide_on_launch = true,
  shape = rrect(),
  app_width = dpi(100),
  app_height = dpi(100),

  background = beautiful.bg_0,
  border_color = beautiful.bg_0,
  prompt_text_color = beautiful.fg_0,
})

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
  awful.key({ shift, alt }, "r", awesome.restart,
    { description = "reload", group = "Awesome" }),

  -- Quit awesome
  awful.key({ shift, alt }, "q", awesome.quit,
    { description = "quit", group = "Awesome" }),

  -- Show help
  awful.key({ mod }, "s", hotkeys_popup.show_help,
    { description = "help", group = "Awesome"}),


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
  end, { description = "Open dashboard", group = "Launchers" }),


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

  -- App launcher
  awful.key({ alt }, "r", function()
    cozy:close_all()
    app_launcher:toggle()
  end, { description = "app launcher", group = "Launchers" }),

  -- Thunar
  awful.key({ alt }, "t", function()
    awful.spawn(apps.default.file_manager)
  end, { description = "file manager", group = "Launchers" }),

  -- -- Bluetooth menu
  -- awful.key({ alt }, "b", function()
  --   awful.spawn(apps.utils.bluetooth)
  -- end, { description = "bluetooth", group = "Launchers" }),
})


-- █▀▀ █░░ █ █▀▀ █▄░█ ▀█▀    █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █▀ 
-- █▄▄ █▄▄ █ ██▄ █░▀█ ░█░    █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ ▄█ 

client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({

    -- Toggle floating
    awful.key({ ctrl, shift }, "g", function()
      client.focus.floating = not client.focus.floating
      client.focus:raise()
    end, { description = "floating", group = "Client" }),

    -- Toggle fullscreen
    awful.key({ ctrl, shift }, "f", function()
      client.focus.fullscreen = not client.focus.fullscreen
      client.focus:raise()
    end, { description = "fullscreen", group = "Client" }),

    -- Toggle sticky
    awful.key({ ctrl, shift }, "d", function()
      client.focus.sticky = not client.focus.sticky
    end, { description = "sticky", group = "Client" }),

    -- Toggle maximize
    awful.key({ ctrl, shift }, "m", function(c)
      c.maximized = not c.maximized
      c:raise()
    end, { description = "(un)maximize", group = "Client" }),

    -- Close window
    awful.key({ ctrl, shift }, "w", function()
      client.focus:kill()
    end, { description = "close", group = "Client" }),

    -- Layout-aware resizing
    awful.key({ alt, shift   }, "h", function () resize_horizontal(0.05) end,
    { group = "Client", description = "(vimlike) resize" }),
    awful.key({ alt, shift   }, "l", function () resize_horizontal(-0.05) end),
    awful.key({ alt, shift   }, "k", function () resize_vertical(-0.05) end),
    awful.key({ alt, shift   }, "j", function () resize_vertical(0.05) end),

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
    awful.client.swap.bydirection("left")
  end, { description = "(v) swap left", group = "Client"}),

  awful.key({ mod, shift }, "j", function()
    awful.client.swap.bydirection("down")
  end),

  awful.key({ mod, shift }, "k", function()
    awful.client.swap.bydirection("up")
  end),

  awful.key({ mod, shift }, "l", function()
    awful.client.swap.bydirection("right")
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

