

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- Manages state (open/closed) for theme switcher.
-- Also provides list of themes.

local cozy    = require("backend.state.cozy")
local gobject = require("gears.object")
local gears   = require("gears")
local gtable  = require("gears.table")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local strutil = require("utils.string")

local themeswitch = {}
local instance = nil

local THEMES_DIR = gfs.get_configuration_dir() .. "/theme/colorschemes/"

---------------------------------------------------------------------

function themeswitch:fetch_themes()
  local cmd = 'ls ' .. THEMES_DIR
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.themes = strutil.split(stdout, '\r\n')
    self:emit_signal("ready::themes")
  end)
end

function themeswitch:fetch_styles(theme)
  local style_dir = THEMES_DIR .. theme .. '/'
  local cmd = 'ls ' .. style_dir .. ' | grep ".lua"'
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local styles = strutil.split(stdout, '\r\n')
    for i = 1, #styles do
      styles[i] = string.gsub(styles[i], ".lua", "")
    end
    self.styles = styles
    self:emit_signal("ready::styles")
  end)
end

function themeswitch:apply()
  print('Applying theme ' .. self.selected_theme .. ': ' .. self.selected_style)

  -- TODO: Ensure that the selected style exists for the selected theme

  -- Update theme name and style in cozyconf
  local config_path = gfs.get_configuration_dir() .. "/cozyconf/ui.lua"
  local replace_theme = "sed -i 's/theme_name.*/theme_name  = \"" ..
                        self.selected_theme .. "\",/' " .. config_path
  local replace_style = "sed -i 's/theme_style.*/theme_style = \"" ..
                        self.selected_style .. "\",/' " .. config_path

  local cmd = replace_theme  .. ' ; ' .. replace_style
  awful.spawn.easy_async_with_shell(cmd, function()
    awesome.restart()
  end)
end

---------------------------------------------------------------------

function themeswitch:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function themeswitch:close()
  self:emit_signal("setstate::close")
  self.visible = false
end

function themeswitch:open()
  cozy:close_all_except("themeswitch")
  self:emit_signal("setstate::open")
  self.visible = true
end

function themeswitch:new()
  self:fetch_themes()
  self.visible = false
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, themeswitch, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
