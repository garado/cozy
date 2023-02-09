
-- █▀█ █▀█ █░█░█ █▀▀ █▀█    █▀█ █▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄    █▄█ █▀▀ ░█░ █ █▄█ █░▀█ ▄█ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local awful   = require("awful")
local wibox   = require("wibox")
local ui      = require("helpers.ui")
local keynav  = require("modules.keynav")
local control = require("core.cozy.control")

-- Power option states
local IDLE  = 0
local CONFIRMING = 1
local state = IDLE

local func  = nil


-- █▄▀ █▀▀ █▄█ █▄░█ ▄▀█ █░█    █▀ █▀▀ ▀█▀ █░█ █▀█ 
-- █░█ ██▄ ░█░ █░▀█ █▀█ ▀▄▀    ▄█ ██▄ ░█░ █▄█ █▀▀ 

local nav_power_opts = keynav.area({
  name     = "power_opts",
  group    = "power_opts",
  is_row   = true,
  circular = true,
})

local nav_power_confirm = keynav.area({
  name     = "power_confirm",
  is_row   = true,
  circular = true,
})

local nav_power = keynav.area({
  name     = "nav_power",
  children = {
    nav_power_opts
  }
})

local yes_btn, nav_yes = ui.simple_button({
  text = "Yes",
  bg   = beautiful.switcher_opt_btn_bg,
  release = function()
    if func ~= nil then func() end
    nav_power:remove_item(nav_power_confirm)
    control:emit_signal("power::confirm_toggle")
  end
})

local no_btn, nav_no = ui.simple_button({
  text = "No",
  bg   = beautiful.switcher_opt_btn_bg,
  release = function()
    state = IDLE
    nav_power:remove_item(nav_power_confirm)
    control:emit_signal("power::confirm_toggle")
  end
})

nav_power_confirm:add(nav_yes)
nav_power_confirm:add(nav_no)


-- █░█ █ 
-- █▄█ █ 

local dialogue = wibox.widget({
  markup = ui.colorize("Shut down?", beautiful.fg_0),
  font   = beautiful.font_bold_s,
  align  = "center",
  widget = wibox.widget.textbox,
  -------
  set_confirm_text = function(self, text)
    local mkup = ui.colorize(text, beautiful.fg_0)
    self:set_markup_silently(mkup)
    state = CONFIRMING
  end
})

local confirmation = wibox.widget({
  {
    {
      dialogue,
      {
        yes_btn,
        no_btn,
        spacing = dpi(20),
        layout  = wibox.layout.fixed.horizontal,
      },
      spacing = dpi(15),
      layout  = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_height = dpi(60),
  visible = false,
  bg      = beautiful.ctrl_powopt_bg,
  widget  = wibox.container.background,
})

local function create_power_btn(icon, confirm_text, cmd)
  local btn, nav_btn = ui.simple_button({
    text = icon,
    bg   = beautiful.bg_2,
    margins = dpi(9),
  })

  function nav_btn:release()
    if not nav_power:contains(nav_power_confirm) then
      nav_power:append(nav_power_confirm)
    end
    dialogue:set_confirm_text(confirm_text)
    control:emit_signal("power::confirm_on")
    func = function()
      if state == CONFIRMING then
        state = IDLE
        control:close()
        awful.spawn(cmd)
      end
    end
  end

  nav_power_opts:add(nav_btn)

  return wibox.widget({
    {
      btn,
      forced_width = dpi(50),
      forced_height = dpi(50),
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  })
end

local options = wibox.widget({
  {
    {
      create_power_btn("", "Sleep?",     "systemctl suspend"),
      create_power_btn("", "Lock?",      "dm-tool lock"),
      create_power_btn("", "Log out?",   "pkill awesome"),
      create_power_btn("", "Restart?",   "systemctl reboot"),
      create_power_btn("", "Shut down?", "systemctl poweroff"),
      layout = wibox.layout.flex.horizontal,
    },
    widget = wibox.container.place,
  },
  forced_width = dpi(220),
  bg     = beautiful.bg_2,
  widget = wibox.container.background,
})

return function()
  return options, confirmation, nav_power
end
