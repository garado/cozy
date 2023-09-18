
-- █▀ █▄█ █▀ ▀█▀ █▀█ ▄▀█ █▄█
-- ▄█ ░█░ ▄█ ░█░ █▀▄ █▀█ ░█░

-- obligatory fuck x11

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local conf  = require("cozyconf")
local wibox = require("wibox")
local rubato = require("modules.rubato")
local cozy  = require("backend.cozy.cozy")

local GAP = beautiful.systray_icon_spacing
local SIZE = dpi(20)

local TRAY_ICONS   = conf.bar_style == "vbar" and {"",""} or {"",""}
local anim_prop    = conf.bar_style == "vbar" and "forced_height" or "forced_width"
local no_anim_prop = conf.bar_style == "vbar" and "forced_width"  or "forced_height"

local do_open_anim = true

local tray = wibox.widget({
  {
    horizontal = not (conf.bar_style == "vbar"),
    base_size = SIZE,
    widget = wibox.widget.systray,
  },
  [anim_prop] = conf.animate and dpi(0) or SIZE,
  [no_anim_prop] = SIZE,
  widget = wibox.container.place,
})

local toggle = ui.textbox({
  text = TRAY_ICONS[2],
  align = "center",
  font = beautiful.font_reg_xs,
  width  = SIZE,
  height = SIZE,
})

local systray_anim
if conf.animate then
  systray_anim = rubato.timed {
    duration = 0.2,
    awestore_compat = true,
    subscribed = function(pos)
      tray[anim_prop] = pos
    end,
    ended = rubato.subscribable(),
  }

  -- After open animation, remove the forced width when systray is
  -- visible so that it can resize dynamically
  systray_anim.ended:subscribe(function()
    if not do_open_anim then tray[anim_prop] = nil end
  end)
end

local widget = wibox.widget({
  tray,
  toggle,
  layout = wibox.layout.fixed[conf.bar_style == "vbar" and "vertical" or "horizontal"],
})

widget:connect_signal("button::press", function()
  if conf.animate then
    -- I patched wibox.widget.systray to expose num_entries because
    -- capi.awesome.systray() to get num entries was not working.
    local cnt = tray.widget.num_entries or 0
    local traysize = (cnt > 0 and (cnt*SIZE) + ((cnt-1)*GAP)) or 0
    systray_anim.target = do_open_anim and traysize or 0
    toggle:update_text(TRAY_ICONS[do_open_anim and 1 or 2])
    do_open_anim = not do_open_anim
  else
    toggle:update_text(TRAY_ICONS[tray.visible and 1 or 2])
    tray.visible = not tray.visible
  end
end)

cozy:connect_signal("systray::toggle", function()
  widget:emit_signal("button::press")
end)

return widget
