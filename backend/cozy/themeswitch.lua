
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄

-- Manages state (open/closed) for theme switcher.
-- Also provides list of themes.

local cozy      = require("backend.cozy.cozy")
local gears     = require("gears")
local gobject   = require("gears.object")
local gtable    = require("gears.table")
local naughty   = require("naughty")
local gfs       = require("gears.filesystem")
local awful     = require("awful")
local strutil   = require("utils.string")
local beautiful = require("beautiful")

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

--- @method generate_lut
-- @brief Generates lookup table used for hot reloading.
function themeswitch:generate_lut()
  local cscheme = require("theme.palettegen")(self.selected_theme, self.selected_style)

  -- Apply wallpaper
  awful.screen.connect_for_each_screen(function(s)
    if cscheme.wall then
      local wall = cscheme.wall
      if type(wall) == "function" then
        wall = wall(s)
      end
      gears.wallpaper.maximized(wall, s, false, nil)
    end
  end)

  -- Apply integrations
  require("theme.integration")(self.selected_theme, self.selected_style)

  -- Generate lut
  local lut = {}
  for i = 100, 900, 100 do lut[beautiful.neutral[i]] = cscheme.neutral[i] end
  for i = 100, 900, 100 do lut[beautiful.primary[i]] = cscheme.primary[i] end
  for i = 100, 500, 100 do lut[beautiful.red[i]]     = cscheme.red[i]     end
  for i = 100, 500, 100 do lut[beautiful.green[i]]   = cscheme.green[i]   end
  for i = 100, 500, 100 do lut[beautiful.yellow[i]]  = cscheme.yellow[i]  end

  for i = 1, #beautiful.accents do
    if i > #cscheme.accents then
      lut[beautiful.accents[i]] = cscheme.accents[1]
    else
      lut[beautiful.accents[i]] = cscheme.accents[i]
    end
  end

  -- Can't find a way to reload beautiful :/ this will have to do
  beautiful.neutral = {}
  beautiful.primary = {}
  beautiful.red     = {}
  beautiful.green   = {}
  beautiful.yellow  = {}

  for i = 100, 900, 100 do beautiful.neutral[i] = cscheme.neutral[i] end
  for i = 100, 900, 100 do beautiful.primary[i] = cscheme.primary[i] end
  for i = 100, 500, 100 do beautiful.red[i]     = cscheme.red[i]     end
  for i = 100, 500, 100 do beautiful.green[i]   = cscheme.green[i]   end
  for i = 100, 500, 100 do beautiful.yellow[i]  = cscheme.yellow[i]  end
  beautiful.accents = cscheme.accents

  -- Borders
  beautiful.border_color_active = beautiful.primary[300]
  beautiful.border_color_normal = beautiful.neutral[900]

  lut[beautiful.accent_image] = cscheme.accent_image

  return lut
end

function themeswitch:apply()
  local path = "theme.colorschemes."..self.selected_theme.."."..self.selected_style
  local _, exists = pcall(path)
  if not exists then
    naughty.notification {
      app_name = "Cozy",
      title = "Theme manager",
      message = "Failed to set theme - please check cozyconf"
    }
    return
  end

  -- Update theme name and style in cozyconf
  local config_path = gfs.get_configuration_dir() .. "/cozyconf/init.lua"
  local replace_theme = "sed -i 's/theme_name.*/theme_name  = \"" ..
                        self.selected_theme .. "\",/' " .. config_path
  local replace_style = "sed -i 's/theme_style.*/theme_style = \"" ..
                        self.selected_style .. "\",/' " .. config_path

  local cmd = replace_theme  .. ' ; ' .. replace_style
  awful.spawn.easy_async_with_shell(cmd, function()
    self:close()
    awesome.emit_signal("theme::reload", self:generate_lut())
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
