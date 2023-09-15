
-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

-- Defines the tag list and project list.
-- This code is a little wonky. Beware.

-- It uses the single select stuff and adds an indicator widget to distinguish
-- between *highlighted* and *selected* items.
-- Highlighted: mouse over or press j/k
-- Selected: clicked or press enter

local ui = require("utils.ui")
local dpi = ui.dpi
local gears = require("gears")
local wibox = require("wibox")
local task  = require("backend.system.task")
local beautiful = require("beautiful")
local singlesel = require("frontend.widget.single-select")

-- Item types
local TAG, PROJECT = 1, 2


-- ▀█▀ ▄▀█ █▀▀ █▀    ▄█▄    █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█    ░▀░    █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 

local select_props = {
  fg = beautiful.primary[400],
  fg_mo = beautiful.primary[500],
  indicator_color = beautiful.neutral[100],
}

local deselect_props = {
  fg = beautiful.neutral[100],
  fg_mo = beautiful.neutral[300],
  indicator_color = beautiful.neutral[800],
}

awesome.connect_signal("theme::reload", function(lut)
  select_props.fg    = lut[select_props.fg]
  select_props.fg_mo = lut[select_props.fg_mo]
  select_props.indicator_color = lut[select_props.indicator_color]
  deselect_props.fg    = lut[deselect_props.fg]
  deselect_props.fg_mo = lut[deselect_props.fg_mo]
  deselect_props.indicator_color = lut[deselect_props.indicator_color]
end)

--- @function gen_badge
-- A badge is a little indicator next to the tag/project name
-- indicating how many tasks are overdue/due very soon within
-- that tag/project.
local function gen_badge()
  local badge = wibox.widget({
    {
      ui.textbox({
        text = "2",
        font = beautiful.font_bold_xs,
        align = "center",
      }),
      margins = dpi(5),
      widget  = wibox.container.margin,
    },
    bg = beautiful.red[500],
    shape = gears.shape.circle,
    widget = wibox.container.background,
    visible = false
  })
  badge.textbox = badge.widget.widget
  return badge
end

--- @function gen_item
-- Generate a tag or project entry
local function gen_item(type, name, parent_tag)
  local tbox = ui.textbox({ text = name })
  local indicator = wibox.widget({
    forced_height = dpi(3),
    forced_width  = dpi(3),
    bg = beautiful.neutral[800],
    shape = gears.shape.circle,
    widget = wibox.container.background,
    visible = true,
  })

  -- Shows number of urgent tasks
  local badge = gen_badge()

  -- Specify when badges should update
  if type == TAG then
    local signal = "ready::duecount::"..name
    task:connect_signal(signal, function(_, num)
      badge.textbox:update_text(num)
      badge.visible = num > 0
    end)
    task:fetch_due_count_tag(name)
  elseif type == PROJECT then
    local signal = "ready::duecount::"..parent_tag.."::"..name
    task:connect_signal(signal, function(_, num)
      badge.textbox:update_text(num)
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
    ---
    props = deselect_props,
    indicator = indicator,
    textbox = tbox,
    tag = parent_tag,
  })

  -- Update UI based on selection status
  function item:update()
    self.props = self.selected and select_props or deselect_props
    self.textbox:update_color(self.props.fg)
    self.indicator.bg = self.props.indicator_color
  end

  -- Select entry (executed on click or on pressing Enter)
  item:connect_signal("button::press", function(self)
    if type == TAG then
      task.active_tag = self.textbox.text
      task:emit_signal("selected::tag", self.textbox.text)
    elseif type == PROJECT then
      task.active_project = self.textbox.text
      task:emit_signal("selected::project", self.tag, self.textbox.text)
    end
  end)

  -- Highlight
  item:connect_signal("mouse::enter", function(self)
    -- Unhighlight last item
    self.parent.active_element.textbox:update_color(beautiful.neutral[100])

    -- Highlight this item
    self.textbox:update_color(beautiful.primary[400])
  end)

  -- Un-highlight
  item:connect_signal("mouse::leave", function(self)
    self.textbox:update_color(self.props.fg)
  end)

  awesome.connect_signal("theme::reload", function(lut)
    item:update()
  end)

  return item
end

-- Set up taglist
local taglist = singlesel({
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
  ---
  keynav = true,
  name = "nav_tags"
})

taglist.area:connect_signal("area::enter", function()
  taglist.active_element:update()
end)

taglist.area:connect_signal("area::left", function()
  taglist.active_element.textbox:update_color(beautiful.neutral[100])
  taglist.area:set_active_element(taglist.active_element)
end)

-- Set up projectlist
local projectlist = singlesel({
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
  ---
  keynav = true,
  name = "nav_projects"
})

projectlist.area:connect_signal("area::enter", function()
  projectlist.active_element:update()
end)

projectlist.area:connect_signal("area::left", function()
  projectlist.active_element.textbox:update_color(beautiful.neutral[100])
  projectlist.area:set_active_element(projectlist.active_element)
end)

-- Final widget assembly -----------
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

-- @function projectlist_update
-- @brief Called when a new tag is selected. Populates projectlist with new projects. 
local function projectlist_update(tag)
  projectlist:clear_elements()

  -- Keep track of project to show on initialization
  local idx = 1

  for i = 1, #task.data[tag] do
    local p = task.data[tag][i]

    if task.restore and task.restore.project == p
    then idx = i
    end

    projectlist:add_element(gen_item(PROJECT, p, tag))
  end

  projectlist.active_element = projectlist.children[idx]
  projectlist.children[idx].selected = true
  projectlist.children[idx]:update()
  projectlist.children[idx].textbox:update_color(beautiful.neutral[100])
  projectlist.area:set_active_element_by_index(idx)

  return task.data[tag][idx]
end

-- Update project list when a new tag is selected.
task:connect_signal("selected::tag", function(_, tag)
  projectlist_update(tag)
end)

-- Initialize taglist and projectlist.
-- Signal emitted on startup or after refresh.
task:connect_signal("ready::tags_and_projects", function()
  taglist:clear_elements()

  -- Sort alphabetically
  -- Need to make a 2nd tmp table because the original table is associative and cannot be
  -- table.sorted (irritating)
  local tagsort = {}
  for t in pairs(task.data) do
    tagsort[#tagsort+1] = t
  end

  table.sort(tagsort, function(a, b) return a:lower() < b:lower() end)

  -- Keep track of the tag to initially show
  local tag_idx = 1

  for i = 1, #tagsort do
    -- Restore position after updating or refreshing
    if task.restore and tagsort[i] == task.restore.tag then
      tag_idx = i
    end

    taglist:add_element(gen_item(TAG, tagsort[i]))
  end

  -- Initialize UI.
  taglist.active_element = taglist.children[tag_idx]
  taglist.children[tag_idx].selected = true
  taglist.children[tag_idx]:update()
  taglist.children[tag_idx].textbox:update_color(beautiful.neutral[100])
  taglist.area:set_active_element_by_index(tag_idx)

  local init_tag = tagsort[tag_idx]
  local init_project = projectlist_update(init_tag)

  task.active_tag = init_tag
  task.active_project = init_project

  task:emit_signal("selected::project", init_tag, init_project)
end)

return function()
  return ui.dashbox(sidebar), taglist.area, projectlist.area
end
