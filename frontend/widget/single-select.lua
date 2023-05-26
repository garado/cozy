
-- █▀ █ █▄░█ █▀▀ █░░ █▀▀    █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀ 
-- ▄█ █ █░▀█ █▄█ █▄▄ ██▄    ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░ 

-- A thingy for a collection of widgets where only one widget can be selected
-- at once. This is my 9 millionth iteration of this because I like to
-- overcomplicate things.

-- This is meant to be called on top of an existing layout widget, i.e.

-- local tasklist = wibox.widget({
--   layout = wibox.layout.fixed.horizontal,
-- })
-- tasklist = singleselect(tasklist)

-- And then when you add widgets, use tasklist:add_element() instead of tasklist:add().

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

local keynav = require("modules.keynav")

local function worker(args)
  local layout = args.layout

  if args.keynav then
    layout.area = keynav.area({
      name = args.name,
      singlesel = layout,
    })
  end

  --- @method add_element
  -- @brief Add a widget to this collection.
  function layout:add_element(widget)
    widget.parent = self

    widget:connect_signal("button::press", function(_self)
      _self.parent:emit_signal("child::press", _self)
    end)

    self:add(widget)

    if layout.area then
      local navitem = keynav.navitem.base({ widget = widget })
      layout.area:append(navitem)
    end
  end

  function layout:clear_elements()
    if self.area then self.area:clear() end
    self:reset()
  end

  layout:connect_signal("child::press", function(self, widget)
    if self.active_element then
      self.active_element.selected = false
      self.active_element:update()
    end

    widget.selected = true
    widget:update()
    self.active_element = widget

    if widget.release then widget:release() end
  end)

  return layout
end

return function(layout) return worker(layout) end
