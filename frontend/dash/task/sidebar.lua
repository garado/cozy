
-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local task  = require("backend.system.task")
local beautiful = require("beautiful")
local singlesel = require("frontend.widget.single-select")

local select_props = {
  fg    = beautiful.primary[400],
  fg_mo = beautiful.primary[500],
}

local deselect_props = {
  fg    = beautiful.fg,
  fg_mo = beautiful.neutral[300],
}

local function gen_tag(tag)
  local item = ui.textbox({ text = tag })
  item.props = deselect_props

  function item:update()
    self.props = self.selected and select_props or deselect_props
    self:update_color(self.props.fg)

  end

  function item:release()
    if not self.selected then return end
    task:emit_signal("selected::tag", self.text)
  end

  item:connect_signal("mouse::enter", function()
    item:update_color(beautiful.red[400])
  end)

  item:connect_signal("mouse::leave", function(self)
    item:update_color(self.props.fg)
  end)

  return item
end

local function gen_project(project)
  local item = ui.textbox({ text = project })
  item.props = deselect_props

  function item:update()
    self.props = self.selected and select_props or deselect_props
    self:update_color(self.props.fg)
  end

  function item:release()
    if not self.selected then return end
    task:emit_signal("selected::project", self.parent.tag, self.text)
  end

  item:connect_signal("mouse::enter", function()
    item:update_color(beautiful.red[400])
  end)

  item:connect_signal("mouse::leave", function(self)
    item:update_color(self.props.fg)
  end)

  return item
end

local taglist = wibox.widget({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})
taglist = singlesel({ layout = taglist, keynav = true, name = "nav_tags" })

local projectlist = wibox.widget({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})
projectlist = singlesel({ layout = projectlist, keynav = true, name = "nav_projects" })

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
    projectlist:add_element(gen_project(p))
  end

  -- Assume first project is selected
  projectlist.active_element = projectlist.children[1]
  projectlist.children[1].selected = true
  projectlist.children[1]:update()
end

-- Initialization
task:connect_signal("ready::tags_and_projects", function()
  taglist:clear_elements()
  for t in pairs(task.data) do
    taglist:add_element(gen_tag(t))
  end

  -- Assume first tag is selected
  -- TODO: Config option to customize this

  taglist.active_element = taglist.children[1]
  taglist.children[1].selected = true
  taglist.children[1]:update()

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
