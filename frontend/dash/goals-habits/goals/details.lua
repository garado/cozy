
-- █▀▄ █▀▀ ▀█▀ ▄▀█ █ █░░ █▀ 
-- █▄▀ ██▄ ░█░ █▀█ █ █▄▄ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash  = require("backend.cozy.dash")
local keynav = require("modules.keynav")

-- █░█ █
-- █▄█ █

local nav_goals_details = keynav.area({
  name = "nav_goals_details",
  keys = {
    ["BackSpace"] = function()
      dash:emit_signal("goals::show_overview")
    end
  },
})

local title = ui.textbox({
  text = "Goal title",
  font = beautiful.font_bold_m,
})

local details = wibox.widget({
  title,
  layout = wibox.layout.fixed.vertical,
})

function details:init(data)
  title:update_text(data.title)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

dash:connect_signal("goals::show_details", function(_, data)
  details:init(data)
end)

details.area = nav_goals_details
return details
