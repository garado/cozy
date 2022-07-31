local awful = require("awful")
local beautiful = require("beautiful")
local ruled = require("ruled")
local helpers = require("helpers")

-- get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

ruled.client.connect_signal("request::rules", function()
  -- GLOBAL --
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

  -- Float
  ruled.client.append_rule({
    id = "floating",
    rule_any = {
      instance = {
        "Thunar",
      },
      class = {
        "Lxappearance",
        "Nm-connection-editor",
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
end)
