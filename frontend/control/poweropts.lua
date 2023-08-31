-- █▀█ █▀█ █░█░█ █▀▀ █▀█
-- █▀▀ █▄█ ▀▄▀▄▀ ██▄ █▀▄

local beautiful           = require("beautiful")
local ui                  = require("utils.ui")
local dpi                 = ui.dpi
local btn                 = require("frontend.widget.button")
local awful               = require("awful")
local wibox               = require("wibox")
local keynav              = require("modules.keynav")
local control             = require("backend.cozy.control")

local poweropts, poweropts_confirm, confirm_text, cmd

-- Keynav setup
local nav_power_opts      = keynav.area({
  name = "nav_poweropts",
})

local nav_power_confirm   = keynav.area({
  name = "nav_power_confirm",
})

local nav_power_container = keynav.area({
  name = "nav_power",
  is_wrapper = true,
  items = {
    nav_power_opts,
  }
})

-- Helper function for creating power option buttons
local function create_poweropt(icon, text, _cmd)
  local opt = btn({
    text  = icon,
    bg    = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
    func  = function()
      -- Show confirm text
      poweropts_confirm.visible = true
      confirm_text:update_text(text)

      -- Add confirm keynav stuff
      if not nav_power_container:contains_area("nav_power_confirm") then
        nav_power_container:append(nav_power_confirm)
      end

      -- Store command so the "yes" button can access and run it later
      cmd = _cmd
    end
  })

  nav_power_opts:append(opt)
  return opt
end

poweropts = wibox.widget({
  {
    create_poweropt("", "Sleep?", "systemctl suspend"),
    create_poweropt("", "Lock?", "dm-tool lock"),
    create_poweropt("", "Log out?", "pkill awesome"),
    create_poweropt("", "Restart?", "systemctl reboot"),
    create_poweropt("", "Shut down?", "systemctl poweroff"),
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal,
  },
  margins = dpi(4),
  widget = wibox.container.margin,
})

------------------

local yes_btn = btn({
  text = "Yes",
  bg = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
  func = function()
    if cmd and cmd ~= "" then
      control:close()
      awful.spawn(cmd)
    end
  end
})

local no_btn = btn({
  text = "Cancel",
  bg = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
  func = function()
    poweropts_confirm.visible = false
    cmd = nil
    nav_power_container:clear()
    nav_power_container:append(nav_power_opts)
  end
})

nav_power_confirm:append(yes_btn)
nav_power_confirm:append(no_btn)

confirm_text = ui.textbox({ text = "Shut down?" })

poweropts_confirm = wibox.widget({
  {
    {
      confirm_text,
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
  bg = beautiful.neutral[800],
  visible = false,
  forced_height = dpi(60),
  widget = wibox.container.background,
})

return function()
  return poweropts, poweropts_confirm, nav_power_container
end
