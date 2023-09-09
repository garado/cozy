
-- █▀█ █ █▀▀ █▀█ █▀▄▀█ 
-- █▀▀ █ █▄▄ █▄█ █░▀░█ 

-- Apply different Picom settings

local beautiful  = require("beautiful")
local ui     = require("utils.ui")
local dpi    = ui.dpi
local wibox  = require("wibox")
local awful  = require("awful")
local gfs    = require("gears.filesystem")
local keynav = require("modules.keynav")
local btn = require("frontend.widget.button")

local HOME = os.getenv("HOME")
local CFG  = gfs.get_configuration_dir()
local PICOM_OPTS_DIR = CFG .. "utils/picom/"
local PICOM_CFG_PATH = HOME .. "/.config/picom.conf"
local PICOM_BACKUP   = HOME .. "/.config/picom.user.conf"
local PICOM_OPTIONS  = { "fancy", "fast", "off" }

local nav_picom = keynav.area({
  name = "nav_picom",
})

--- Create an option button
-- @param opt A picom option (see PICOM_OPTIONS)
local function create_option_btn(opt)
  local option = btn({
    text = opt:gsub("^%l", string.upper),
    shape = ui.rrect(dpi(2)),
    height = dpi(35),
    bg = beautiful.neutral[600],
    bg_mo = beautiful.neutral[500],
    margins = {
      top    = dpi(8),
      bottom = dpi(8),
      left   = dpi(15),
      right  = dpi(15),
    },
    on_release = function()
      if opt == "off" then
        local cmd = "pkill picom"
        awful.spawn.easy_async_with_shell(cmd, function() end)
        return
      end

      -- Create backup of user's config if necessary
      if gfs.file_readable(PICOM_CFG_PATH) then
        if not gfs.file_readable(PICOM_BACKUP) then
          local cmd = "cp " .. PICOM_CFG_PATH .. " " .. PICOM_BACKUP
          awful.spawn.easy_async_with_shell(cmd, function() end)
        end
      end

      -- Set desired setting by copying new config
      local config_name = PICOM_OPTS_DIR .. opt .. ".conf"
      local cmd = "cp " .. config_name .. ' ' .. PICOM_CFG_PATH
      awful.spawn.easy_async_with_shell(cmd, function()
        awful.spawn.easy_async_with_shell("picom")
      end)
    end
  })

  return option
end

local option_btns = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.fixed.horizontal,
})

local picom = wibox.widget({
  {
    ui.textbox({
      text = "Animations",
      color = beautiful.neutral[100],
      align = "center",
    }),
    option_btns,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

for i = 1, #PICOM_OPTIONS do
  local pbtn = create_option_btn(PICOM_OPTIONS[i])
  option_btns:add(pbtn)
  nav_picom:append(pbtn)
end

return function()
  return picom, nav_picom
end
