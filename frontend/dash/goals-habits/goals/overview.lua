
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Shows all goals.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local keynav = require("modules.keynav")
local colors = require("utils.color")
local gstate = require("backend.system.goals")

local nav_goals_short = keynav.area({
  name = "nav_goals_short"
})

local nav_goals_long = keynav.area({
  name = "nav_goals_long"
})

--- Generate a goalbox.
local function gen_goal(data)
  -- Each focus category gets a different set of colors
  -- TODO: Looks terrible
  -- local fcolors = data.focus and g.focus[data.focus] or g.focus_default
  local fcolors = gstate.focus_default

  local icon = ui.textbox({
    text  = data.icon or "",
    align = "center",
    color = fcolors[2],
    font  = beautiful.font_reg_m,
  })

  local title = ui.textbox({
    text  = data.description,
    font  = beautiful.font_bold_s,
    color = fcolors[2],
  })

  local subtitle = ui.textbox({
    text  = data.deadline,
    color = beautiful.primary[600],
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
    bg = fcolors[1],
    shape  = ui.rrect(),
    forced_width = dpi(290),
    widget = wibox.container.background,
    ---
    data = data,
  })

  goalbox:connect_signal("mouse::enter", function(self)
    -- self.bg = colors.darken(fcolors[1], 0.2)
    self.bg = beautiful.primary[300]
  end)

  goalbox:connect_signal("mouse::leave", function(self)
    self.bg = fcolors[1]
  end)

  goalbox:connect_signal("button::press", function(self)
    gstate:emit_signal("goals::show_roadmap", self.data)
  end)

  goalbox.navitem = keynav.navitem.base({ widget = goalbox })

  return goalbox
end

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local short_goals = wibox.widget({
  forced_num_cols = 4,
  spacing = dpi(10),
  layout = wibox.layout.grid,
})

local short = wibox.widget({
  ui.textbox({
    text = "Short-term",
    font = beautiful.font_bold_m,
  }),
  short_goals,
  spacing = dpi(12),
  layout = wibox.layout.fixed.vertical,
})

function short:init()
  nav_goals_short:clear()
  short_goals:reset()
  for i = 1, #gstate.shortterm do
    local goal = gen_goal(gstate.shortterm[i])
    short_goals:add(goal)
    nav_goals_short:append(goal.navitem)
  end
end

------------------

local long_goals = wibox.widget({
  forced_num_cols = 4,
  spacing = dpi(10),
  layout = wibox.layout.grid,
})

local long = wibox.widget({
  ui.textbox({
    text = "Long-term",
    font = beautiful.font_bold_m,
  }),
  long_goals,
  spacing = dpi(12),
  layout = wibox.layout.fixed.vertical,
})

function long:init()
  nav_goals_long:clear()
  long_goals:reset()
  for i = 1, #gstate.longterm do
    local goal = gen_goal(gstate.longterm[i])
    long_goals:add(goal)
    nav_goals_long:append(goal.navitem)
  end
end

local overview = wibox.widget({
  long,
  short,
  spacing = dpi(25),
  forced_height  = dpi(2000),
  layout  = wibox.layout.fixed.vertical,
})

overview.areas = {
  nav_goals_long,
  nav_goals_short,
}

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

gstate:connect_signal("ready::shortterm", short.init)
gstate:connect_signal("ready::longterm", long.init)

return overview
