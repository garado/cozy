
-- █▀█ █▀█ ▄▀█ █▀▄ █▀▄▀█ ▄▀█ █▀█ 
-- █▀▄ █▄█ █▀█ █▄▀ █░▀░█ █▀█ █▀▀ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local goals = require("backend.system.goals")
local keynav = require("modules.keynav")

local nav_goals_roadmap = keynav.area({
  name = "nav_goals_roadmap",
  keys = {
    ["BackSpace"] = function()
      goals:emit_signal("goals::show_overview")
    end,
    ["r"] = function()
      goals:gen_twdeps_image()
    end
  },
})

local roadmap = wibox.widget({
  resize = false,
  widget = wibox.widget.imagebox,
})

local roadmap_container = wibox.widget({
  nil,
  {
    roadmap,
    widget = wibox.container.place,
  },
  nil,
  layout = wibox.layout.align.vertical,
  forced_width  = dpi(2000),
  forced_height = dpi(2000),
  -----
  area = nav_goals_roadmap
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

goals:connect_signal("goals::show_roadmap", function(_, data)
  roadmap.image = nil
  goals:gen_twdeps_image(data.id, data.project)
end)

goals:connect_signal("ready::image", function()
  roadmap.image = gears.surface.load_uncached(goals.deps_img_path)
end)

return roadmap_container
