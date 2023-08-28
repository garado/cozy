
-- █▀▀ █▀█ ▀█ █▄█ █▀▀ █▀█ █▄░█ █▀▀ 
-- █▄▄ █▄█ █▄ ░█░ █▄▄ █▄█ █░▀█ █▀░ 

-- Cozy configuration options.

-- Other things you might want to change:
--    > profile picture theme/assets/pfp.png

return {

  -- █░█ █
  -- █▄█ █

  -- Set desired theme and style.
  -- Default available options:
  --    > [mountain] fuji
  --    > [nord] dark light
  theme_name  = "rose-pine",
  theme_style = "main",

  -- If Cozy's theme switcher should try to switch themes for other applications.
  -- See `theme/integration.lua` for details and setup examples.
  theme_switch_integration = true,

  -- Font style to use. It'll generate every combination of weights and sizes.
  -- Make sure the weights for your font actually exist.
  -- Name/weight strings must have a trailing space!
  font = {
    name = "Circular Std ",
    weights = {
      light = "Light ",
      reg   = "Regular ",
      med   = "Medium ",
      bold  = "Bold ",
    },
    sizes = {
      xxs = 5,
      xs  = 8,
      s   = 11,
      m   = 15,
      l   = 20,
      xl  = 28,
      xxl = 35,
    },

  },

  -- For scaling UI size up and down.
  -- This only affects AwesomeWM widgets.
  scale = 1,

  -- Set bar style. Default style is vertical.
  -- Options: horizontal vertical
  bar_style = "horizontal",

  -- Set bar alignment.
  -- Options (horizontal): top bottom
  -- Options (vertical): left right
  bar_align = "top",

  -- Show notifications for playerctl - they look cool but they get annoying fast.
  playerctl_notifications = false,

  -- █▀▄▀█ █ █▀ █▀▀ 
  -- █░▀░█ █ ▄█ █▄▄ 

  -- GMT offset.
  timezone = -7,

  -- OpenWeather.
  weather = {
    key = "API_KEY_HERE",
    lat = "36.9741",
    lon = "-122.0308",

    -- Options: imperial metric standard
    -- standard is in Kelvin
    unit = "imperial",
  },

  -- █▀▄ ▄▀█ █▀ █░█ 
  -- █▄▀ █▀█ ▄█ █▀█ 

  ---------------------------
  -------- MAIN TAB ---------
  ---------------------------

  -- The name to display on the main tab.
  name = "Alexis",

  -- Github username for contributions widget.
  github_username = "garado",

  -- List of titles to display beneath profile picture.
  titles = {
    "Vim enthusiast",
    "Mechromancer",
    "Uses Arch btw",
    "Open sourcerer",
    "Vim wizard",
    "CLI sorcerer",
    "Linux enthusiast",
    "Unofficial 5th member of Polyphia",
  },

  -- Icon shown on bar and at bottom of dash sidebar.
  distro_icon = "",

  -- Selectable Timewarrior sessions.
  -- NOTE: Timewarrior module not functional yet.
  timewarrior_sessions = {
    "Applications",
    "Cozy",
    "Hobby",
    "Personal",
  },

  -- Graph IDs of daily habits to track.
  -- Used with Pixela: https://pixe.la/
  habits = {
    "coding",
    "ledger",
    "studying",
    "journal",
    "outside",
    "music",
  },

  ----------------------------
  --------- LEDGER -----------
  ----------------------------

  ledger = {
    ledger_file  = "$HOME/Documents/Ledger/2023.ledger",
    budget_file  = "$HOME/Documents/Ledger/budget.ledger",
    account_file = "$HOME/Documents/Ledger/accounts.ledger",
  },

  ----------------------------
  --------- CALENDAR ---------
  ----------------------------

  calendar = {
    start_hour = 8,
    end_hour   = 21, -- Shows through end hour
  },

  -- TODO: No other tabs implemented yet lol so this doesn't work
  -- The default page to display when the calendar tab is open.
  -- Options: week schedule overview
  cal_default_tab = "overview",
}
