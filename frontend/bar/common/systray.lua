
-- █▀ █▄█ █▀ ▀█▀ █▀█ ▄▀█ █▄█
-- ▄█ ░█░ ▄█ ░█░ █▀▄ █▀█ ░█░

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local conf  = require("cozyconf")
local wibox = require("wibox")
local rubato = require("modules.rubato")
local cozy  = require("backend.cozy.cozy")
local sysctrl = require("backend.cozy").systray_control

local GAP = beautiful.systray_icon_spacing
local SIZE = dpi(20)

local TRAY_ICONS   = conf.bar_style == "vbar" and {"",""} or {"",""}
local anim_prop    = conf.bar_style == "vbar" and "forced_height" or "forced_width"
local no_anim_prop = conf.bar_style == "vbar" and "forced_width"  or "forced_height"

return function(s)
  local widget = wibox.widget({
    wibox.widget({
      [anim_prop] = conf.animate and dpi(0),
      [no_anim_prop] = SIZE,
      widget = wibox.container.place,
      do_open_anim = true
    }),
    ui.textbox({
      text = TRAY_ICONS[2],
      align = "center",
      font = beautiful.font_reg_xs,
      width  = SIZE,
      height = SIZE,
    }),
    layout = wibox.layout.fixed[conf.bar_style == "vbar" and "vertical" or "horizontal"],
  })

  local tray_container = widget.children[1]
  local toggle = widget.children[2]

  local systray_anim
  if conf.animate then
    systray_anim = rubato.timed {
      duration = 0.2,
      awestore_compat = true,
      subscribed = function(pos)
        tray_container[anim_prop] = pos
      end,
    }

    -- After open animation, remove the forced width when systray is
    -- visible so that it can resize dynamically
    systray_anim.ended:subscribe(function()
      if not tray_container.do_open_anim then tray_container[anim_prop] = nil end
    end)
  end

  function tray_container:force_close()
    if conf.animate then
      toggle:update_text(TRAY_ICONS[self.do_open_anim and 1 or 2])
      tray_container.do_open_anim = true
    else
      toggle:update_text(TRAY_ICONS[self.visible and 1 or 2])
      tray_container.visible = false
    end
  end

  function tray_container:toggle_systray(num_entries)
    if conf.animate then
      local traysize = (num_entries > 0 and (num_entries*SIZE) + ((num_entries-1)*GAP)) or 0
      systray_anim.target = tray_container.do_open_anim and traysize or 0
      toggle:update_text(TRAY_ICONS[tray_container.do_open_anim and 1 or 2])
      tray_container.do_open_anim = not tray_container.do_open_anim
    else
      toggle:update_text(TRAY_ICONS[tray_container.visible and 1 or 2])
      tray_container.visible = not tray_container.visible
    end
  end

  widget:connect_signal("button::press", function()
    sysctrl:request_tray(tray_container, s)
  end)

  cozy:connect_signal("systray::toggle", function()
    widget:emit_signal("button::press")
  end)

  return widget
end
