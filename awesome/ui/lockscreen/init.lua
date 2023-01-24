
-- █░░ █▀█ █▀▀ █▄▀ █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- █▄▄ █▄█ █▄▄ █░█ ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

-- PIN lockscreen for touchscreen devices.
-- THIS IS NOT BULLETPROOF AND IT IS NOT MEANT TO BE.
-- Anyone with enough linux knowledge will be able to bypass this, but this is
-- sufficient to prevent the average person from being able to unlock your system.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local ui = require("helpers.ui")
local config = require("config")
local keynav = require("modules.keynav") -- todo add keyboard support

local enter_input, lockscreen

-- █ █▄░█ █▀█ █░█ ▀█▀    █░█ █ 
-- █ █░▀█ █▀▀ █▄█ ░█░    █▄█ █ 

local title = wibox.widget({
  markup = ui.colorize("Enter Passcode", beautiful.fg),
  align  = "center",
  valign = "center",
  font   = beautiful.base_small_font,
  widget = wibox.widget.textbox,
})

local input_feedback = wibox.widget({
  {
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
  ----
  reset_input = function(self)
    for i = 1, #self.children[1].children do
      self.children[1].children[i]:unfill()
    end
  end
})

for _ = 1, #config.lock.pin do
  local circle = wibox.widget({
    forced_height = dpi(10),
    forced_width  = dpi(10),
    border_width = dpi(2),
    border_color = beautiful.bg,
    shape  = gears.shape.circle,
    widget = wibox.container.background,
    -----
    fill = function(self)
      self.border_width = dpi(0)
      self.bg = beautiful.bg
    end,
    unfill = function(self)
      self.border_width = dpi(2)
      self.bg = nil
    end
  })
  input_feedback.children[1]:add(circle)
end

-- █▀█ █ █▄░█ █▀█ ▄▀█ █▀▄ 
-- █▀▀ █ █░▀█ █▀▀ █▀█ █▄▀ 

local function add_pinbutton (num, field)
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      enter_input(field or num)
    end)
  )

  return {
    {
      {
        markup = ui.colorize(num, beautiful.fg),
        font   = beautiful.base_small_font,
        align  = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      forced_height = dpi(50),
      forced_width  = dpi(50),
      bg     = beautiful.bg_l2,
      shape  = gears.shape.circle,
      layout = wibox.container.background,
    },
    widget  = wibox.container.place,
    -----
    value   = num,
    buttons = buttons
  }
end

local pinpad = wibox.widget({
    orientation     = "vertical",
    forced_num_cols = 3,
    forced_num_rows = 4,
    spacing = dpi(15),
    layout = wibox.layout.grid
})


for i = 1, 9 do
  local btn = add_pinbutton(i)
  pinpad:add(btn)

  if i == 9 then
    btn = add_pinbutton(0)
    pinpad:add(btn)
    btn = add_pinbutton('󰭜', 'delete')
    pinpad:add(btn)
  end
end


-- █▀▄ █▀▀ █▀▀ █▀█ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▄▀ ██▄ █▄▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

local pfp = wibox.widget({
  {
    {
      image  = beautiful.pfp,
      resize = true,
      forced_height = dpi(130),
      forced_width  = dpi(130),
      layout = wibox.widget.imagebox,
    },
    bg     = beautiful.main_accent,
    shape  = gears.shape.circle,
    widget = wibox.container.background,
  },
  widget = wibox.container.place,
})

-- █▀▀ █▄░█ ▀█▀ █▀█ █▄█ 
-- ██▄ █░▀█ ░█░ █▀▄ ░█░ 

local values_entered = {}

local function unlock_success()
  input_feedback:reset_input()
  values_entered = {}
  awesome.emit_signal("lockscreen::toggle")
end

local function unlock_failed()
  input_feedback:reset_input()
  values_entered = {}
end

local function try_unlock()
  for i = 1, string.len(config.lock.pin) do
    if string.sub(config.lock.pin, i, i) ~= tostring(values_entered[i]) then
      unlock_failed()
      return
    end
  end
  unlock_success()
end

function enter_input(input)
  if input == "delete" and #values_entered > 0 then
    input_feedback.children[1].children[#values_entered]:unfill()
    table.remove(values_entered, #values_entered)
  else
    table.insert(values_entered, input)
    input_feedback.children[1].children[#values_entered]:fill()
  end

  if #values_entered == #config.lock.pin then
    try_unlock()
  end
end

return function(s)
  lockscreen = awful.popup({
    type = "splash",
    minimum_height = s.height,
    maximum_height = s.height,
    minimum_width  = s.width,
    maximum_width  = s.width,
    ontop     = true,
    visible   = true,
    placement = awful.placement.centered,
    widget = ({
      {
        image  = beautiful.lockscreen_bg or beautiful.wallpaper,
        resize = true,
        align  = "center",
        valign = "center",
        widget = wibox.widget.imagebox,
      },
      {
        nil,
        {
          {
            pfp,
            title,
            input_feedback,
            pinpad,
            spacing = dpi(16),
            layout  = wibox.layout.fixed.vertical,
          },
          widget = wibox.container.place,
        },
        nil,
        spacing = dpi(15),
        layout  = wibox.layout.align.vertical,
      },
      layout = wibox.layout.stack,
    }),
  })

  awesome.connect_signal("lockscreen::toggle", function()
    lockscreen.visible = not lockscreen.visible
  end)
end
