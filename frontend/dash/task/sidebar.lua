
-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local task  = require("backend.system.task")
local beautiful = require("beautiful")
local singlesel = require("frontend.widget.single-select")

-- Item types
local TAG = 1
local PROJECT = 2

local select_props = {
  fg    = beautiful.primary[400],
  fg_mo = beautiful.primary[500],
  indicator_color = beautiful.fg,
}

local deselect_props = {
  fg    = beautiful.fg,
  fg_mo = beautiful.neutral[300],
  indicator_color = beautiful.neutral[800],
}

-- Generate a tag or project entry
local function gen_item(type, name)
  local tbox = ui.textbox({ text = name })
  local indicator = wibox.widget({
    forced_height = dpi(3),
    forced_width  = dpi(3),
    bg = beautiful.neutral[800],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
    visible = true,
  })

  local item = wibox.widget({
    indicator,
    tbox,
    spacing = dpi(10),
    layout = wibox.layout.fixed.horizontal,
  })

  item.props = deselect_props

  -- Update UI
  function item:update()
    self.props = self.selected and select_props or deselect_props
    tbox:update_color(self.props.fg)
    indicator.bg = self.props.indicator_color
  end

  function item:release()
    if not self.selected then return end
    if type == TAG then
      task:emit_signal("selected::tag", tbox.text)
    elseif type == PROJECT then
      task:emit_signal("selected::project", self.parent.tag, tbox.text)
    end
  end

  item:connect_signal("mouse::enter", function(self)
    self.parent.active_element.children[2]:update_color(beautiful.fg)
    tbox:update_color(beautiful.primary[400])
  end)

  item:connect_signal("mouse::leave", function(self)
    tbox:update_color(self.props.fg)
  end)

  return item
end

local taglist = wibox.widget({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})
taglist = singlesel({ layout = taglist, keynav = true, name = "nav_tags" })

taglist.area:connect_signal("area::enter", function()
  taglist.active_element:update()
end)

taglist.area:connect_signal("area::left", function()
  taglist.active_element.children[2]:update_color(beautiful.fg)
end)

local projectlist = wibox.widget({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})
projectlist = singlesel({ layout = projectlist, keynav = true, name = "nav_projects" })

projectlist.area:connect_signal("area::left", function()
  projectlist.active_element.children[2]:update_color(beautiful.fg)
end)

projectlist.area:connect_signal("area::enter", function()
  projectlist.active_element:update()
end)

local sidebar = wibox.widget({
  { -- Tags
    ui.textbox({
      text = "Tags",
      font = beautiful.font_med_m,
    }),
    taglist,
    spacing = dpi(15),
    layout  = wibox.layout.fixed.vertical,
  },
  { -- Projects
    ui.textbox({
      text = "Projects",
      font = beautiful.font_med_m,
    }),
    projectlist,
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(25),
  layout  = wibox.layout.fixed.vertical,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- Called when a new tag is selected
local function projectlist_update(tag)
  projectlist.tag = tag

  projectlist:clear_elements()
  for i = 1, #task.data[tag] do
    local p = task.data[tag][i]
    projectlist:add_element(gen_item(PROJECT, p))
  end

  -- Assume first project is selected
  projectlist.active_element = projectlist.children[1]
  projectlist.children[1].selected = true
  projectlist.children[1]:update()
  projectlist.children[1].children[2]:update_color(beautiful.fg)
end

-- Initialization
task:connect_signal("ready::tags_and_projects", function()
  taglist:clear_elements()
  for t in pairs(task.data) do
    taglist:add_element(gen_item(TAG, t))
  end

  -- Assume first tag is selected
  -- TODO: Config option to customize this

  taglist.active_element = taglist.children[1]
  taglist.children[1].selected = true
  taglist.children[1]:update()
  taglist.children[1].children[2]:update_color(beautiful.fg)

  local first_tag = next(task.data)
  projectlist_update(first_tag)

  task:emit_signal("selected::project", first_tag, task.data[first_tag][1])
end)

-- Update project list when a new task is selected
task:connect_signal("selected::tag", function(_, tag)
  projectlist_update(tag)
end)

return function()
  return ui.dashbox(sidebar), taglist.area, projectlist.area
end
