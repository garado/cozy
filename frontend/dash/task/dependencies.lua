
-- █▀▄ █▀▀ █▀█ █▀▀ █▄░█ █▀▄ █▀▀ █▄░█ █▀▀ █ █▀▀ █▀ 
-- █▄▀ ██▄ █▀▀ ██▄ █░▀█ █▄▀ ██▄ █░▀█ █▄▄ █ ██▄ ▄█ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local task = require("backend.system.task")
local keynav = require("modules.keynav")

local nav_dependencies = keynav.area({
  name = "nav_dependencies",
  keys = {
    ["BackSpace"] = function()
      task:emit_signal("task::show_tasklist")
    end,
    ["r"] = function()
      task:gen_twdeps_image()
    end
  },
})

local roadmap = wibox.widget({
  nil,
  {
    {
      resize = false,
      widget = wibox.widget.imagebox,
    },
    widget = wibox.container.place,
  },
  nil,
  forced_height = dpi(2000),
  layout = wibox.layout.align.vertical,
  -----
  area = nav_dependencies
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

task:connect_signal("task::show_roadmap", function()
  roadmap.image = nil
  task:gen_twdeps_image()
end)

task:connect_signal("ready::image", function()
  local file = gears.surface.load_uncached(task.deps_img_path)
  roadmap.children[1].widget.image = file
end)

return roadmap
