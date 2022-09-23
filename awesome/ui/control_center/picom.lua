
-- █▀█ █ █▀▀ █▀█ █▀▄▀█ 
-- █▀▀ █ █▄▄ █▄█ █░▀░█ 
-- Toggles Picom presets

local beautiful = require("beautiful")
local wibox = require("wibox")
local widgets = require("ui.widgets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local awful = require("awful")
local gfs = require("gears.filesystem")
local helpers = require("helpers")
local Area = require("modules.keynav.area")
local Elevated = require("modules.keynav.navitem").Elevated

local nav_picom = Area:new({
  name = "picom",
  is_row = true,
  circular = true,
})

local cfg = gfs.get_configuration_dir()
local picom_cfgs = cfg .. "utils/ctrl/picom/"

local function create_option_btn(opt)
  local btn = widgets.button.text.normal({
    text = opt:gsub("^%l", string.upper),
    text_normal_bg = beautiful.ctrl_link_fg,
    normal_bg = beautiful.ctrl_link_bg,
    animate_size = false,
    font = beautiful.font,
    size = 11,
    on_release = function()
      -- Create backup of user's config if it doesn't exist 
      local backup = "~/.config/picom.user.conf"
      if not gfs.file_readable(backup) then
        awful.spawn.with_shell("cp ~/.config/picom.conf " .. backup)
      end

      local fname = picom_cfgs .. opt .. ".conf"
      local cmd = "cp " .. fname .. " ~/.config/picom.conf"
      awful.spawn.with_shell(cmd)
      if opt == "off" then
        awful.spawn.with_shell("pkill picom")
      end
    end
  })
  nav_picom:append(Elevated:new(btn))
  return btn
end

local widget = wibox.widget({
  {
    {
      markup = helpers.ui.colorize_text("ANIMATIONS", beautiful.ctrl_header_fg),
      align = "center",
      valign = "center",
      font = beautiful.font_name .. "10",
      widget = wibox.widget.textbox,
    },
    {
      spacing = dpi(15),
      layout = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

local opts = {"fancy", "fast", "off"}
for i = 1, #opts do
  local btn = create_option_btn(opts[i])
  widget.children[1].children[2]:add(btn)
end

return function()
  return nav_picom, widget
end
