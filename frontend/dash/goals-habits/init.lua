
-- █▀▀ █▀█ ▄▀█ █░░ █▀    ▄▀█ █▄░█ █▀▄    █░█ ▄▀█ █▄▄ █ ▀█▀ █▀ 
-- █▄█ █▄█ █▀█ █▄▄ ▄█    █▀█ █░▀█ █▄▀    █▀█ █▀█ █▄█ █ ░█░ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local header = require("frontend.widget.dashheader")
local dash  = require("backend.cozy.dash")
local keynav = require("modules.keynav")
local gstate = require("backend.system.goals")

-- Modules
local goals     = require(... .. ".goals")
local timeline  = require(... .. ".timeline")

local nav_goals_habits = keynav.area({
  name  = "nav_goals_habits",
  items = {
    goals.area
  },
  keys  = {
    ["r"] = function()
      gstate:fetch_shortterm()
      gstate:fetch_longterm()
    end
  },
})

---------------------

local goals_header = header({
  title_text = "Goals & habits",
  actions = {
    {
      text = "Refresh",
      func = function()
        goals:emit_signal("goals::refresh")
      end,
    },
  },
  pages = {
    {
      text = "Goals",
    },
    {
      text = "Habits"
    },
    {
      text = "Timeline",
    },
  }
})

local content = goals

------------------

goals:connect_signal("goals::show_details", function(_, data)
  goals_header:update_title({ text = data.description })
end)

goals:connect_signal("goals::show_overview", function()
  goals_header:update_title({ text = "Goals &amp; habits" })
end)

content = wibox.widget({
  content,
  margins = dpi(15),
  forced_width  = dpi(2000),
  forced_height = dpi(2000),
  widget  = wibox.container.margin,
})

local container = ui.contentbox(goals_header, content)

return function()
  return container, nav_goals_habits
end
