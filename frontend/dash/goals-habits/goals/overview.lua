
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Shows all goals.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local keynav = require("modules.keynav")
local goals_short = require("cozyconf.goals.short")
local goals_long  = require("cozyconf.goals.long")
local dash  = require("backend.cozy.dash")

local nav_goals_overview = keynav.area({
  name = "nav_goals_overview",
})

--- Generate a goalbox.
local function gen_goal(data)
  local icon = ui.textbox({
    text  = data.icon,
    align = "center",
    color = beautiful.primary[700],
    font  = beautiful.font_reg_m,
  })

  local title = ui.textbox({
    text  = data.title,
    font  = beautiful.font_bold_s,
    color = beautiful.primary[700],
  })

  local subtitle = ui.textbox({
    text  = data.timeline,
    color = beautiful.primary[700],
  })

  local goalbox = wibox.widget({
    {
      {
        icon,
        {
          title,
          subtitle,
          spacing = dpi(8),
          layout = wibox.layout.fixed.vertical,
        },
        spacing = dpi(12),
        layout = wibox.layout.fixed.horizontal,
      },
      margins = dpi(15),
      widget  = wibox.container.margin,
    },
    bg = beautiful.primary[100],
    shape  = ui.rrect(),
    forced_width = dpi(290),
    widget = wibox.container.background,
    ---
    data = data,
  })

  goalbox:connect_signal("mouse::enter", function(self)
    self.bg = beautiful.primary[300]
  end)

  goalbox:connect_signal("mouse::leave", function(self)
    self.bg = beautiful.primary[100]
  end)

  goalbox:connect_signal("button::press", function(self)
    dash:emit_signal("goals::show_details", self.data)
  end)

  local navitem = keynav.navitem.base({ widget = goalbox })
  nav_goals_overview:append(navitem)

  return goalbox
end

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local short_title = ui.textbox({
  text = "Short-term",
  font = beautiful.font_bold_m,
})

local short_goals = wibox.widget({
  -- forced_num_cols = 4,
  orientation = "horizontal",
  spacing = dpi(10),
  layout = wibox.layout.grid,
})

local short = wibox.widget({
  short_title,
  short_goals,
  spacing = dpi(12),
  layout = wibox.layout.fixed.vertical,
})

function short:init()
  short_goals:reset()
  for i = 1, #goals_short do
    short_goals:add(gen_goal(goals_short[i]))
  end
end

------------------

local long_title = ui.textbox({
  text = "Long-term",
  font = beautiful.font_bold_m,
})

local long_goals = wibox.widget({
  orientation = "horizontal",
  -- forced_num_cols = 4,
  spacing = dpi(10),
  layout = wibox.layout.grid,
})

local long = wibox.widget({
  long_title,
  long_goals,
  spacing = dpi(12),
  layout = wibox.layout.fixed.vertical,
})

function long:init()
  long_goals:reset()
  for i = 1, #goals_long do
    long_goals:add(gen_goal(goals_long[i]))
  end
end

local goals = wibox.widget({
  long,
  short,
  spacing = dpi(25),
  layout  = wibox.layout.fixed.vertical,
  ----
  area = nav_goals_overview,
})

short:init()
long:init()

dash:connect_signal("goals::refresh", function()
  package.loaded["cozyconf.goals.short"] = nil
  package.loaded["cozyconf.goals.long"] = nil
  goals_short = require("cozyconf.goals.short")
  goals_long  = require("cozyconf.goals.long")

  goals.area:clear()

  short:init()
  long:init()
end)

return goals
