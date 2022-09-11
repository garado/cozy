
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀▀ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ ██▄ 

-- Keyboard navigation for theme switcher.

-- Tree structure:
-- * L1: Themes
--    * Catppuccin
--    * Dracula
--    * Etc
-- * L2: Styles
--    * Dark
--    * Light
-- * L3: Actions
--    * Apply
--    * Cancel

local awful = require("awful")

local function navigate(navtree)
  local tree    = navtree:get_tree()
  local levels  = #tree
  local curr_level  = 1
  local curr_elem   = 1

  awesome.connect_signal("nav::update_navtree", function(new_tree)
    navtree = new_tree
    tree    = navtree:get_tree()
    levels  = #tree
  end)

  -- Helper functions
  local function get_curr_elem()
    return navtree:get_elem(curr_level, curr_elem)
  end

  -- Action functions
  local function hl_toggle()
    local elem = get_curr_elem()
    if elem then
      awesome.emit_signal("nav::" .. elem .. "::hl_toggle")
    end
  end
  hl_toggle()

  local function hl_off()
    local elem = get_curr_elem()
    if elem then
      awesome.emit_signal("nav::" .. elem .. "::hl_off")
    end
  end

  local function release()
    local signal = "nav::" .. get_curr_elem() .. "::release"
    awesome.emit_signal(signal)
  end

  local function switch_level(num)
    curr_level = ((curr_level + num) % levels)
    if curr_level == 0 then curr_level = levels end
    curr_elem = 1
    if get_curr_elem() == nil then
      switch_level(num)
    end
  end

  local function switch_elem(num)
    local elems_in_level = #tree[curr_level]
    curr_elem = curr_elem + num
    if curr_elem > elems_in_level then
      switch_level(num)
      curr_elem = 1
    elseif curr_elem == 0 then
      switch_level(num)
      curr_elem = #tree[curr_level]
    end
  end

  local function keypressed(_, _, key, _)
    if key == "Mod4"    then hl_toggle() end
    if key ~= "Return"  then hl_toggle() end

    if     key == "h" then
      switch_elem(-1)
    elseif key == "j" then
      switch_elem(1)
    elseif key == "k" then
      switch_elem(-1)
    elseif key == "l" then
      switch_elem(1)
    elseif key == "BackSpace" then
      switch_level(-1)
    elseif key == "Tab" then
      switch_level(1)
    elseif key == "Return" then
      release()
    end

    if key ~= "Return" then hl_toggle() end
  end

  awful.keygrabber {
    stop_key = "Mod4",
    stop_event = "press",
    autostart = true,
    keypressed_callback = keypressed,
    stop_callback = function()
      hl_off()
      curr_level  = 1
      curr_elem   = 1
    end
  }
end

return navigate
