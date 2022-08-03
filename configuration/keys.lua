
-- █▄▀ █▀▀ █▄█ █▀
-- █░█ ██▄ ░█░ ▄█

local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require("beautiful")
local apps = require("configuration.apps")

-- Make key easier to call
mod = "Mod4"
alt = "Mod1"
ctrl = "Control"
shift = "Shift"

-- Global key bindings
awful.keyboard.append_global_keybindings({

  -- temp --
  awful.key({ mod }, "w", function()
    local naughty = require("naughty")
    naughty.notification {
      title = "Title",
      message = "This is example message text",
    }
  end, { description = "test notification", group = "_Temporary" }),

  -- WM --
  -- Restart awesome
  awful.key({ shift, alt }, "r", awesome.restart, 
    { description = "reload awesome", group = "WM" }),

  -- Quit awesome
  awful.key({ shift, alt }, "q", awesome.quit, 
    { description = "quit awesome", group = "WM" }),

  -- Show help
  awful.key({ mod }, "s", hotkeys_popup.show_help, 
    { description = "show help", group = "WM"}),

  -----

  awful.key({ mod }, "j", function()
    awesome.emit_signal("dash::toggle", s)
  end, { description = "open dash", group = "Apps" }),


  -- SYSTEM --  
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set 5%+ -q", false)
		awesome.emit_signal("module::brightness")
	end, { description = "increase brightness", group = "Hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 5%- -q", false)
		awesome.emit_signal("module::brightness")
	end, { description = "decrease brightness", group = "Hotkeys" }),

	--- Audio control
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn("pamixer -u ; pamixer -i 5", false)
		awesome.emit_signal("module::volume")
	end, { description = "increase volume", group = "Hotkeys" }),

	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn("pamixer -u ; pamixer -d 5", false)
		awesome.emit_signal("module::volume")
	end, { description = "decrease volume", group = "Hotkeys" }),
  
	awful.key({}, "XF86AudioMute", function()
		awful.spawn("pamixer -t", false)
		awesome.emit_signal("module::volume")
	end, { description = "mute volume", group = "Hotkeys" }),
  
  awful.key({mod}, "XF86AudioLowerVolume", function()
    awful.spawn("playerctl play-pause", false)
  end, { description = "play/pause track", group = "Hotkeys" }),
  
  awful.key({mod}, "XF86AudioMute", function()
    awful.spawn("playerctl previous", false)
  end, { description = "previous track", group = "Hotkeys" }),

  awful.key({mod}, "XF86AudioRaiseVolume", function()
    awful.spawn("playerctl next", false)
  end, { description = "next track", group = "Hotkeys" }),

  -----

  -- APPS -- 
  -- Terminal
  awful.key({ alt }, "Return", function()
    awful.spawn(apps.default.terminal)
  end, { description = "open terminal", group = "Apps" }), 
  
  -----

  -- ROFI --
  -- App launcher
  awful.key({ alt }, "r", function()
    awful.spawn.with_shell(apps.utils.app_launcher)
  end, { description = "app launcher", group = "Rofi" }), 

  -- Tmux presets
  awful.key({ alt }, "e", function()
    awful.spawn.with_shell(apps.utils.tmux_pane_presets)
  end, { description = "tmux pane presets", group = "Rofi" }), 

  -- Bluetooth
  awful.key({ alt }, "b", function()
    awful.spawn.with_shell(apps.utils.bluetooth)
  end, { description = "bluetooth", group = "Rofi" }), 
  
})

-- Client keybindings
-- ~~~~~~~~~~~~~~~~~~
client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    -- Toggle floating

    -- Toggle fullscreen
    -- awful.key({ mod }, "f", function()
    --   client.focus.fullscreen = not client.focus.fullscren
    --   client.focus:raise()
    -- end),
    
    -- Close window
    awful.key({ ctrl, shift }, "w", function()
      client.focus:kill()
    end, { description = "close window", group = "Client" })

  })
end)

-- Workspaces 
-- ~~~~~~~~~~~~~~~~~~~~~~
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
  })
})

