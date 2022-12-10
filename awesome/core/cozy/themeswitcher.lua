
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- Handles backend for theme switcher.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local config = require("config")
local naughty = require("naughty")

local themeswitcher = { }
local instance = nil

local themes_dir = gfs.get_configuration_dir() .. "theme/colorschemes/"
local displayed_themes = config.displayed_themes

---------------------------------------------------------------------

function themeswitcher:toggle()
  if self._private.visible then
    self:close()
  else
    self:open()
  end
end

function themeswitcher:close()
  self:emit_signal("updatestate::close")
  self._private.visible = false
  self:reset()
end

function themeswitcher:open()
  cozy:close_all()
  self:emit_signal("updatestate::open")
  self._private.visible = true
end

--- Fetch themes from config
function themeswitcher:fetch_themes()
  -- Check if should load only selected themes
  local restrict_themes = gears.table.count_keys(displayed_themes) ~= 0

  local cmd = "ls " .. themes_dir
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    for theme in string.gmatch(stdout, "[^\n\r]+") do
      theme = string.gsub(theme, ".lua", "")
      if restrict_themes and displayed_themes[theme] and theme ~= "init" then
        self._private.themes[theme] = {}
        self._private.total_themes = self._private.total_themes + 1
      end
    end

    self:fetch_styles()
  end)

end

--- Checks all files within a theme directory
function themeswitcher:fetch_styles()
  local cfg = gfs.get_configuration_dir()
  for theme, _ in pairs(self._private.themes) do

    local dir = cfg .. "theme/colorschemes/" .. theme .. "/"
    local cmd = "ls " .. dir
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      for style in string.gmatch(stdout, "[^\n\r]+") do
        if style ~= "init.lua" then
          style = string.gsub(style, ".lua", "")
          table.insert(self._private.themes[theme], style)
        end
      end

      -- When all async calls are finished, emit the signal to update theme switcher UI
      self._private.themes_fetched = self._private.themes_fetched + 1
      if self._private.themes_fetched >= self._private.total_themes then
        self:emit_signal("update::themes")
      end
    end)

  end -- end for theme in pairs(themes)
end

function themeswitcher:apply_selected_theme()
  local theme = self:get_selected_theme()
  local style = self:get_selected_style()

  -- Ensure that the selected style exists for the selected theme
  if not gears.table.hasitem(self:get_themes()[theme], style)  == nil then
    naughty.notification {
      app_name = "System notification",
      title = "Theme switcher error",
      message = "Could not find style "..style.." for theme "..theme,
    }
    return
  end

  local cfg = gfs.get_configuration_dir()
  local path = cfg .. "theme/colorschemes/" .. theme .. "/" .. style .. ".lua"
  local theme_exists = gfs.file_readable(path)
  if not theme_exists or style == "" or style == nil then
    naughty.notification {
      app_name = "System notification",
      title = "Theme switcher",
      message = "Select a style to proceed!",
    }
    return
  end
  local config_path = gfs.get_configuration_dir() .. "config.lua"
  local replace_theme = "sed -i 's/theme_name.*/theme_name = \"" .. theme .. "\",/' "
  local replace_style = "sed -i 's/theme_style.*/theme_style = \"" .. style .. "\",/' "
  awful.spawn.with_shell(replace_theme .. config_path)
  awful.spawn.with_shell(replace_style .. config_path)
  awesome.restart()
end

---------------------------------------------------------------------

--- Returns the table of themes
function themeswitcher:get_themes()
  return self._private.themes
end

--- Return table of styles for a specific theme
function themeswitcher:get_styles(theme)
  return self._private.themes[theme]
end

function themeswitcher:get_applied_theme()
  return self._private.applied_theme
end

function themeswitcher:get_applied_style()
  return self._private.applied_style
end

function themeswitcher:get_selected_theme()
  return self._private.selected_theme
end

function themeswitcher:get_selected_style()
  return self._private.selected_style
end

function themeswitcher:set_applied_theme(theme)
  self._private.applied_theme = theme
end

function themeswitcher:set_applied_style(style)
  self._private.applied_style = style
end

function themeswitcher:set_selected_theme(theme)
  self._private.selected_theme = theme
end

function themeswitcher:set_selected_style(style)
  self._private.selected_style = style
end

---------------------------------------------------------------------

function themeswitcher:reset()
  self._private = {}
  self._private.themes_fetched = 0
  self._private.total_themes = 0
  self._private.visible = false
  self._private.applied_theme = config.theme_name
  self._private.applied_style = config.theme_style
  self._private.selected_theme = ""
  self._private.selected_style = ""
  self._private.themes = {}
  self:fetch_themes()
end

function themeswitcher:new()
  self._private = {}
  self._private.visible = false
  self._private.applied_theme = config.theme_name
  self._private.applied_style = config.theme_style
  self._private.selected_theme = ""
  self._private.selected_style = ""
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, themeswitcher, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
