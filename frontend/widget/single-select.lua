
-- █▀ █ █▄░█ █▀▀ █░░ █▀▀    █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀
-- ▄█ █ █░▀█ █▄█ █▄▄ ██▄    ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░

-- A container for a collection of widgets where only one widget can be selected at once.

-- Call it like this:

-- local singlesel = require("frontend/widget/single-select")
-- local tasklist = singlesel({
--   spacing = dpi(10),
--   layout  = wibox.layout.fixed.vertical,
--   ---
--   keynav = true,
--   name = "nav_tasklist"
-- })

-- When you add widgets, use tasklist:add_element() instead of tasklist:add().
-- To reset the layout, use tasklist:clear_elements() instead of tasklist:reset().

-- Every widget that gets added to a single-select container MUST have an update()
-- function that determines how the widget acts and looks when it is selected/deselected.
-- You'll write the update function yourself. It might look something like this:

-- local widget = wibox.widget({
--   text = "Textbox",
--   widget = wibox.widget.textbox,
-- })

-- function widget:update()
--   self.text = self.selected and "Selected!" or "Deselected!"
-- end

-- Singleselect will set the 'selected' field for you.

local ui = require("utils.ui")
local wibox = require("wibox")
local keynav = require("modules.keynav")
local beautiful = require("beautiful")

local function worker(args)
  local layout = wibox.widget(args)

  -- Initialization
  if args.keynav then
    layout.area = keynav.area({
      name = args.name,
      singlesel = layout,
    })

    if args.scroll then
      layout.first_visible_index = 1
      layout.previous_index = 1
      layout.overflow_top = {}
      layout.overflow_bottom = {}

      layout.scrollbar = wibox.widget({
        {
          {
            id = "bar",
            value = 0,
            forced_height = ui.dpi(5), -- since it's rotated, this is width
            bar_color     = beautiful.neutral[700],
            handle_color  = beautiful.primary[600],
            handle_border_width = 0,
            shape = ui.rrect(),
            bar_shape = ui.rrect(),
            widget = wibox.widget.slider,
          },
          direction = "west",
          widget    = wibox.container.rotate,
        },
        right = ui.dpi(15),
        widget = wibox.container.margin,
      })

      layout.bar = layout.scrollbar.children[1].widget
    end
  end

  --- @method add_element
  -- @brief Add a widget to this collection.
  function layout:add_element(widget)
    widget.parent = self

    widget:connect_signal("button::press", function(_self)
      self:update_selections(_self)
    end)

    if self.scroll then
      if #self.children < self.max_visible_elements then
        self:add(widget)
      else
        self.overflow_bottom[#self.overflow_bottom+1] = widget
      end
      self.scrollbar.visible = #self.overflow_bottom > 0
    else
      self:add(widget)
    end

    if layout.area then layout.area:append(widget) end

    if args.autoset_first and #self.children == 1 then
      widget:emit_signal("button::press")
    end
  end

  --- @method clear_elements
  -- take a wild guess
  function layout:clear_elements()
    if self.area then self.area:clear() end

    if self.scroll then
      self.overflow_bottom = {}
      self.overflow_top = {}
    end

    self:reset()
  end

  --- @method update_selections
  -- @brief Deselect previously selected element and select new one.
  -- @params new_selection The newly selected element.
  function layout:update_selections(new_selection)
    if self.active_element then
      self.active_element.selected = false
      self.active_element:update()
    end

    new_selection.selected = true
    new_selection:update()
    self.active_element = new_selection
  end


  -- █▀ █▀▀ █▀█ █▀█ █░░ █░░ 
  -- ▄█ █▄▄ █▀▄ █▄█ █▄▄ █▄▄ 

  -- How scrolling works:
  -- > Only visible elements are added to the layout.
  -- > There are two overflow buffers - overflow_top and overflow_bottom - where all hidden elements are
  --   stored.
  -- > Every time you move around, the update() function updates the contents of the 
  --   layout to reflect the current position within the navarea.

  --- @method total_overflow
  -- @brief Simple utility function to get total number of not visible tasks
  function layout:total_overflow()
    return #self.overflow_top + #self.overflow_bottom
  end

  --- @method update
  -- @brief Update contents of layout to reflect current position within navarea.
  function layout:update()
    if self:total_overflow() == 0 then return end

    self.last_visible_index = self.first_visible_index + self.max_visible_elements - 1
    local index = self.area.active_element.index
    local num_elements = #self.children + self:total_overflow()

    -- Distance between currently selected element and the previously selected element
    local gap = math.abs(index - self.previous_index)

    if index == 1 and gap > 1 then
      if self.first_visible_index == 1 then return end
      self:jump_top()
    elseif index == num_elements and gap > 1 then
      if self.first_visible_index == num_elements then return end
      self:jump_end()
    elseif index < self.first_visible_index and gap == 1 then
      self:scroll_up()
    elseif index > self.last_visible_index and gap == 1 then
      self:scroll_down()
    elseif index == math.floor(num_elements / 2) then
      -- BUG: not working
      -- self:jump_mid()
    end

    self.previous_index = index
  end

  --- @method scroll_up
  function layout:scroll_up()
    self.first_visible_index = self.first_visible_index - 1
    self.bar.value = self.bar.value - 1

    -- NOTE: This was in the old code, no idea what the fuck it's doing but it doesn't work without it
    if #self.children > (self.first_visible_index + self.max_visible_elements) then
      self.last_visible_index = self.first_visible_index + self.max_visible_elements + 1
    else
      self.last_visible_index = #self.children
    end

    -- When scrolling up, the last visible element gets prepended to overflow_bottom
    table.insert(self.overflow_bottom, 1, self.children[self.last_visible_index])
    self:remove(#self.children)

    -- Prepend last task from overflow_top to layout
    self:insert(1, self.overflow_top[#self.overflow_top])
    table.remove(self.overflow_top, #self.overflow_top)
  end

  --- @method scroll_down
  function layout:scroll_down()
    self.first_visible_index = self.first_visible_index + 1
    self.bar.value = self.bar.value + 1

    -- When scrolling down, the first visible element gets appended to overflow_bottom
    self.overflow_top[#self.overflow_top+1] = self.children[1]
    self:remove(1)

    -- Append the first element from overflow_bottom to layout
    self:add(self.overflow_bottom[1])
    table.remove(self.overflow_bottom, 1)
  end

  --- @method jump_mid
  -- BUG: Not really working
  function layout:jump_mid()
    local midpoint = math.floor(self:total_overflow() / 2)

    if #self.overflow_top > #self.overflow_bottom then
      while #self.overflow_top > midpoint do
        self:scroll_down()
      end
    else
      while #self.overflow_bottom > midpoint do
        self:scroll_up()
      end
    end
  end

  --- @method jump_top
  function layout:jump_top()
    while #self.overflow_top > 0 do
      self:scroll_up()
    end
    self.area:set_active_element_by_index(1)
  end

  --- @method jump_end
  function layout:jump_end()
    while #self.overflow_bottom > 0 do
      self:scroll_down()
    end

    local total_elements = #self.children + self:total_overflow()
    self.area:set_active_element_by_index(total_elements)
  end

  function layout:update_scrollbar()
    if self:total_overflow() == 0 then
      self.scrollbar.visible = false
      return
    end

    local num_elements = #self.children + self:total_overflow()
    self.bar.handle_width = ((self.max_visible_elements / num_elements) * ui.dpi(550))
    self.bar.maximum = (self:total_overflow() > 1 and self:total_overflow()) or 1
    self.scrollbar.visible = true
  end

  return layout
end

return function(layout) return worker(layout) end
