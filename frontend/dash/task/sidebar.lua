
-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

-- Defines the tag list and project list.
-- This code is a little wonky. Beware.

-- It uses the single select stuff and adds indicators on top of it to distinguish
-- between *highlighted* and *selected* items.
-- Selected: currently chosen.
-- Highlighted: just a mouseover.

local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local task  = require("backend.system.task")
local beautiful = require("beautiful")
local cozyconf  = require("cozyconf")
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

--- Generate badge.
-- A badge is a little indicator next to the tag/project name
-- indicating how many tasks are overdue/due very soon within
-- that tag/project.
local function gen_badge()
  return wibox.widget({
    {
      ui.textbox({
        text = "2",
        font = beautiful.font_bold_xs,
        align = "center",
      }),
      margins = dpi(5),
      widget  = wibox.container.margin,
    },
    bg     = beautiful.red[500],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
    visible = false
  })
end

-- Generate a tag or project entry
local function gen_item(type, name, parent_tag)
  local tbox = ui.textbox({ text = name })
  local indicator = wibox.widget({
    forced_height = dpi(3),
    forced_width  = dpi(3),
    bg = beautiful.neutral[800],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
    visible = true,
  })

  -- Shows number of urgent tasks
  local badge = gen_badge()

  if type == TAG then
    local signal = "ready::duecount::"..name
    task:connect_signal(signal, function(_, num)
      badge.widget.widget:update_text(num)
      badge.visible = num > 0
    end)
    task:fetch_due_count_tag(name)
  elseif type == PROJECT then
    local signal = "ready::duecount::"..parent_tag.."::"..name
    task:connect_signal(signal, function(_, num)
      badge.widget.widget:update_text(num)
      badge.visible = num > 0
    end)
    task:fetch_due_count_project(parent_tag, name)
  end

  local item = wibox.widget({
    indicator,
    tbox,
    badge,
    spacing = dpi(10),
    forced_height = dpi(18),
    layout = wibox.layout.fixed.horizontal,
  })

  item.props = deselect_props

  -- Update UI
  function item:update()
    self.props = self.selected and select_props or deselect_props
    tbox:update_color(self.props.fg)
    indicator.bg = self.props.indicator_color
  end

  -- Executed on click or on pressing Enter
  function item:release()
    if not self.selected then return end
    if type == TAG then
      task.active_tag = tbox.text
      task:emit_signal("selected::tag", tbox.text)
    elseif type == PROJECT then
      task.active_project = tbox.text
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
  taglist.area:set_active_element(taglist.active_element.navitem)
end)

local projectlist = wibox.widget({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})
projectlist = singlesel({ layout = projectlist, keynav = true, name = "nav_projects" })

projectlist.area:connect_signal("area::enter", function()
  projectlist.active_element:update()
end)

projectlist.area:connect_signal("area::left", function()
  projectlist.active_element.children[2]:update_color(beautiful.fg)
  projectlist.area:set_active_element(projectlist.active_element.navitem)
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

  -- Keep track of project to show on initialization
  local idx = 1

  for i = 1, #task.data[tag] do
    local p = task.data[tag][i]
    if task.restore and task.restore.project == p then idx = i end
    projectlist:add_element(gen_item(PROJECT, p, tag))
  end

  projectlist.active_element = projectlist.children[idx]
  projectlist.children[idx].selected = true
  projectlist.children[idx]:update()
  projectlist.children[idx].children[2]:update_color(beautiful.fg)
  projectlist.area:set_active_element_by_index(idx)

  return task.data[tag][idx]
end

-- Initialization
task:connect_signal("ready::tags_and_projects", function()
  taglist:clear_elements()

  -- Sort alphabetically
  -- Need to make a 2nd temp table because the original table is associative and cannot be
  -- sorted (irritating)
  local tagsort = {}
  for t in pairs(task.data) do
    tagsort[#tagsort+1] = t
  end

  table.sort(tagsort, function(a, b) return a:lower() < b:lower() end)

  -- Keep track of the tag to initially show
  local tag_idx = 1

  for i = 1, #tagsort do
    if task.restore and tagsort[i] == task.restore.tag then
      tag_idx = i
    end
    taglist:add_element(gen_item(TAG, tagsort[i]))
  end

  taglist.active_element = taglist.children[tag_idx]
  taglist.children[tag_idx].selected = true
  taglist.children[tag_idx]:update()
  taglist.children[tag_idx].children[2]:update_color(beautiful.fg)
  taglist.area:set_active_element_by_index(tag_idx)

  local init_tag = tagsort[tag_idx]
  local init_project = projectlist_update(init_tag)

  task.active_tag = init_tag
  task.active_project = init_project

  task:emit_signal("selected::project", init_tag, init_project)
end)

-- Update project list when a new task is selected
task:connect_signal("selected::tag", function(_, tag)
  projectlist_update(tag)
end)

return function()
  return ui.dashbox(sidebar), taglist.area, projectlist.area
end
