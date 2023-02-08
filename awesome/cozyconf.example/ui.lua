
-- █░█ █    █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- █▄█ █    ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

return {

  -- If bar is horizontal (top) or vertical (left).
  -- There is currently no implementation for configuring placement.
  -- NOTE: horizontal bar is definitely a work in progress.
  barstyle = "vertical",

  theme_name  = "yoru",
  theme_style = "dark",

  -- Possible values: modern
  fontset = "modern",

  -- If the theme switcher changes the theme of other apps as well.
  -- Edit awesome/theme/theme_integrations.lua to customize which apps are affected.
  theme_switch_integration = true,

  -- Define displayed_themes if you want to only show specific themes
  -- in the theme switcher; otherwise comment it out
  displayed_themes = {
    ["mountain"]  = true,
    ["kanagawa"]  = true,
    ["nord"]      = true,
    ["yoru"]      = true,
    ["rose-pine"] = true,
  },

}

