
-- █ █▄░█ ▀█▀ █▀▀ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █ █░▀█ ░█░ ██▄ █▄█ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 

-- Functions for automagically matching your system colorscheme
-- to Cozy's colorscheme. :-)

local defined_integrations = require("cozyconf.integrations")

-- @param name  The name of the theme to switch to
-- @param style The style of the theme to switch to
return function(name, style)
  local theme = require("theme.colorschemes." .. name .. '.' .. style)

  for app_name, app_theme in pairs(theme.integrations) do
  if defined_integrations[app_name] then
      defined_integrations[app_name](app_theme)
    end
  end
end
