
-- █▀█ █░█ █ █▀▀ █▄▀    ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█    █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local ui  = require("utils.ui")
local dpi = ui.dpi
local wibox     = require("wibox")
local keynav    = require("modules.keynav")
local control   = require("backend.cozy.control")
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
  local action = actions[i]

  action:connect_signal("mouse::enter", function(self)
    header:update_text(self.name)
  end)

  action:connect_signal("mouse::leave", function()
    header:update_text("Quick Actions")
  end)

  qactions.widget.children[2]:add(action)
  nav_qactions:append(action)
end

return function()
  return qactions, nav_qactions
end
