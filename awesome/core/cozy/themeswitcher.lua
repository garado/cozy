
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

-- Backend for theme switcher responsible for managing popup state
-- and applying/updating themes.

local cozy = require("core.cozy.cozy")
local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")
local gears = require("gears")
local gfs = require("gears.filesystem")
local config = require("cozyconf")
local naughty = require("naughty")

local themeswitcher = { }
local instance = nil

local themes_dir = gfs.get_configuration_dir() .. "theme/colorschemes/"
local displayed_themes = config.displayed_themes

---------------------------------------------------------------------

function themeswitcher:toggle()
  if self.visible then
    self:close()
  else
    self:open()
  end
end

function themeswitcher:close()
  self:emit_signal("setstate::close")
  self.visible = false
  self:reset()
end

function themeswitcher:open()
  cozy:close_all_except("themeswitcher")
  self:emit_signal("setstate::open")
  self.visible = true
end

--- Fetch themes from config
function themeswitcher:fetch_themes()
  -- Check if should load only selected themes
  local restrict_themes = gears.table.count_keys(displayed_themes) ~= 0

  local cmd = "ls " .. themes_dir
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    for theme in string.gmatch(stdout, "[^\n\r]+") do
      theme = string.gsub(theme, ".lua", "")
      if restrict_themes and displayed_themes[theme] and theme ~= "init.lua" then
        self.themes[theme] = {}
        self.total_themes = self.total_themes + 1
      end
    end

    self:fetch_styles()
  end)

end

--- Checks all files within a theme directory
function themeswitcher:fetch_styles()
  local cfg = gfs.get_configuration_dir()
  for theme, _ in pairs(self.themes) do

    local dir = cfg .. "theme/colorschemes/" .. theme .. "/"
    local cmd = "ls " .. dir .. " | grep '.lua'"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      for style in string.gmatch(stdout, "[^\n\r]+") do
        if style ~= "init.lua" then
          style = string.gsub(style, ".lua", "")
          table.insert(self.themes[theme], style)
        end
      end

      -- When all async calls are finished, emit the signal to update theme switcher UI
      self.themes_fetched = self.themes_fetched + 1
      if self.themes_fetched >= self.total_themes then
        self:emit_signal("update::themes")
      end
    end)

  end
end

function themeswitcher:apply_selected_theme()
  local theme = self.selected_theme
  local style = self.selected_style

  -- Ensure that the selected style exists for the selected theme
  if not gears.table.hasitem(self.themes[theme], style)  == nil then
    naughty.notification {
      app_name = "System notification",
      title    = "Theme switcher error",
      message  = "Could not find style "..style.." for theme "..theme,
    }
    return
  end

  local cfg = gfs.get_configuration_dir()
  local path = cfg .. "theme/colorschemes/" .. theme .. "/" .. style .. ".lua"
  local theme_exists = gfs.file_readable(path)
  if not theme_exists or style == "" or style == nil then
    naughty.notification {
      app_name = "System notification",
      title    = "Theme switcher",
      message  = "Select a style to proceed!",
    }
    return
  end

  local config_path = gfs.get_configuration_dir() .. "/cozyconf/ui.lua"
  local replace_theme = "sed -i 's/theme_name.*/theme_name  = \"" .. theme .. "\",/' " .. config_path
  local replace_style = "sed -i 's/theme_style.*/theme_style = \"" .. style .. "\",/' " .. config_path

  local cmd = replace_theme  .. ' ; ' .. replace_style

  awful.spawn.easy_async_with_shell(cmd, function()
    awesome.restart()
  end)
end

--------------

function themeswitcher:reset()
  self.themes_fetched = 0
  self.total_themes = 0
  self.visible = false
  self.applied_theme = config.theme_name
  self.applied_style = config.theme_style
  self.selected_theme = ""
  self.selected_style = ""
  self.themes = {}
  self:fetch_themes()
end

function themeswitcher:new()
  self.visible = false
  self.applied_theme = config.theme_name
  self.applied_style = config.theme_style
  self.selected_theme = ""
  self.selected_style = ""
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, themeswitcher, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
