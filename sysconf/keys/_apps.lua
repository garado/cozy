
-- ▄▀█ █▀█ █▀█    █░█ █▀█ ▀█▀ █▄▀ █▀▀ █▄█ █▀ 
-- █▀█ █▀▀ █▀▀    █▀█ █▄█ ░█░ █░█ ██▄ ░█░ ▄█ 

-- Application-specific hotkeys to show in the hotkeys popup.

local hotkeys = require("sysconf.keys")

-- █▄░█ █░█ █ █▀▄▀█
-- █░▀█ ▀▄▀ █ █░▀░█

local nvim = { class = { "nvim", "Nvim" } }
for group_name, group_data in pairs({
  ["Nvim"] = { color = "#009F00", rule_any = nvim }
}) do
  hotkeys.add_group_rules(group_name, group_data)
end

hotkeys.add_hotkeys({
  ["Firefox: tabs"] = {{
    modifiers = { "Mod1" },
    keys = {
      ["1..9"] = "go to tab"
    }
  }, {
      modifiers = { "Ctrl" },
      keys = {
        t = "new tab",
        w = 'close tab',
        ['Tab'] = "next tab"
      }
    }, {
      modifiers = { "Ctrl", "Shift" },
      keys = {
        ['Tab'] = "previous tab"
      }
    }}
})
