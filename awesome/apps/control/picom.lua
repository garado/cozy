
-- █▀█ █ █▀▀ █▀█ █▀▄▀█ 
-- █▀▀ █ █▄▄ █▄█ █░▀░█ 

-- Buttons that change Picom configurations by copying
-- different Picom configs

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi    = xresources.apply_dpi
local wibox  = require("wibox")
local awful  = require("awful")
local gfs    = require("gears.filesystem")
local keynav = require("modules.keynav")
local ui     = require("helpers.ui")

local HOME = os.getenv("HOME")
local CFG  = gfs.get_configuration_dir()
local PICOM_OPTS_DIR = CFG .. "utils/ctrl/picom/"
local PICOM_CFG_PATH = HOME .. "/.config/picom.conf"
local PICOM_BACKUP   = HOME .. "/.config/picom.user.conf"
local PICOM_OPTIONS  = {"fancy", "fast", "off"}

--- Create an option button
-- @param opt A picom option (see PICOM_OPTIONS)
local function create_option_btn(opt)
  return ui.simple_button({
    text    = opt:gsub("^%l", string.upper),
    font    = beautiful.font_reg_s,
    margins = {
      top    = dpi(8),
      bottom = dpi(8),
      left   = dpi(15),
      right  = dpi(15),
    },
    release = function()
      -- Create backup of user's config if necessary
      if gfs.file_readable(PICOM_CFG_PATH) then
        if not gfs.file_readable(PICOM_BACKUP) then
          local cmd = "cp " .. PICOM_CFG_PATH .. " " .. PICOM_BACKUP
          print(cmd)
          awful.spawn.easy_async_with_shell(cmd, function() end)
        end
      end

      -- Set desired setting by symlinking new config
      local config_name = PICOM_OPTS_DIR .. opt .. ".conf"
      local cmd = "cp " .. config_name .. ' ' .. PICOM_CFG_PATH
      if opt == "off" then
        awful.spawn.with_shell("pkill picom")
      else
        awful.spawn.easy_async_with_shell(cmd, function() end)
      end
    end
  })
end

local option_btns = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.fixed.horizontal,
})

local picom = wibox.widget({
  {
    {
      markup = ui.colorize("ANIMATIONS", beautiful.ctrl_header_fg),
      font   = beautiful.font_reg_xs,
      align  = "center",
      widget = wibox.widget.textbox,
    },
    option_btns,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

local nav_picom = keynav.area({
  name     = "picom",
  is_row   = true,
  circular = true,
})

for i = 1, #PICOM_OPTIONS do
  local btn, nav_btn = create_option_btn(PICOM_OPTIONS[i])
  option_btns:add(btn)
  nav_picom:add(nav_btn)
end

return function()
  return picom, nav_picom
end
