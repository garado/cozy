
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀▀ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ ██▄ 

local naughty = require("naughty")
local awful = require("awful")

-- oooh boy
local function navigate(navtree)
  local tree = navtree:get_tree()

  awesome.connect_signal("nav::update_navtree", function(new_tree)
    navtree = new_tree
    tree = navtree:get_tree()
  end)

  local levels = #tree
  local curr_level = 1
  local curr_elem  = 1

  local function get_curr_elem()
    return navtree:get_elem(curr_level, curr_elem)
  end

  local function hl_off()
    local elem = get_curr_elem()
    if elem then
      awesome.emit_signal("nav::" .. elem .. "::hl_off")
    end
  end

  local function hl_toggle()
    local elem = get_curr_elem()
    if elem then
      awesome.emit_signal("nav::" .. elem .. "::hl_toggle")
    end
  end
  hl_toggle()

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
    end
  end

  local function release()
    local signal = "nav::" .. get_curr_elem() .. "::release"
    awesome.emit_signal(signal)
  end

  local function keypressed(self, mod, key, command)
    if key == "Mod4" then hl_toggle() end
    if key ~= "Return" then hl_toggle() end

    if     key == "h" then
      switch_elem(1)
    elseif key == "l" then
      switch_elem(-1)
    elseif key == "j" then
      switch_elem(1)
    elseif key == "k" then
      switch_elem(-1)
    elseif key == "k" then
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
    timeout = 5,
    keypressed_callback = keypressed,
    stop_callback = function()
      curr_level  = 1
      curr_elem   = 1
      hl_off()
    end
  }
end

return navigate
