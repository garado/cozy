
-- █▀█ █░█ █ █▀▀ █▄▀    ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█    █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local ui  = require("utils.ui")
local dpi = ui.dpi
local btn = require("frontend.widget.button")
local wibox     = require("wibox")
local keynav    = require("modules.keynav")
local control   = require("backend.cozy.control")
local beautiful = require("beautiful")
local actions   = require("cozyconf.actions")

local nav_qactions = keynav.area({
  name = "qactions",
  is_grid = true,
  num_rows = 2,
  num_cols = 5,
})

local header = ui.textbox({
  text  = "Quick Actions",
  align = "center",
})

local qactions = wibox.widget({
  {
    header,
    {
      forced_num_rows = 2,
      forced_num_cols = 5,
      homogeneous     = true,
      spacing         = dpi(15),
      layout          = wibox.layout.grid,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

-- why doesn't children = actions work :(
for i = 1, #actions do
  qactions.widget.children[2]:add(actions[i])
  nav_qactions:append( keynav.navitem.base({ widget = actions[i] }) )
end

control:connect_signal("qaction::selected", function(_, name)
  header:update_text(name)
end)

return function()
  return qactions, nav_qactions
end
