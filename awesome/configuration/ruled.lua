
-- █▀█ █░█ █░░ █▀▀ █▀▄ 
-- █▀▄ █▄█ █▄▄ ██▄ █▄▀ 

local awful = require("awful")
local ruled = require("ruled")
local helpers = require("helpers")

ruled.client.connect_signal("request::rules", function()
  -- Rules applied to every window
  ruled.client.append_rule({
    id = "global",
    rule = { },
    properties = {
      raise = true,
      size_hints_honor = false,
      honor_workarea = true,
      honor_padding = true,
      screen = awful.screen.focused,
      focus = awful.client.focus.filter,
      titlebars_enabled = false,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    },
  })

  -- Set certain applications as floating
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = {
        "Thunar",
        "feh",
        "simplescreenrecorder",
        "mpv",
      },
      class = {
        "Pavucontrol",
        "Lxappearance",
        "Nm-connection-editor",
        "qBittorrent",
        "mpv",
      },
      role = {
        "GtkFileChooserDialog",
        "conversation",
      },
      type = {
        "dialog",
      },
    },
    properties = {
      floating = true,
      placement = helpers.client.centered_client_placement,
    },
  })

  -- Force window height for certain applications
  ruled.client.append_rule({
    rule_any = {
      instance = {
        "Thunar",
      },
      class = {
        "Pavucontrol",
      },
    },
    properties = {
      height = 700,
    },
  })

  -- Rules for onscreen keyboard
  ruled.client.append_rule({
    rule_any = {
      instance = { "onboard" },
    },
    properties = {
      floating = true,
      placement = helpers.client.centered_client_placement,
    },
  })
end)
