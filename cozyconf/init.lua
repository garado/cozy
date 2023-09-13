
-- █▀▀ █▀█ ▀█ █▄█ █▀▀ █▀█ █▄░█ █▀▀
-- █▄▄ █▄█ █▄ ░█░ █▄▄ █▄█ █░▀█ █▀░

-- Cozy configuration options.

-- Other things you might want to change:
--    > profile picture: theme/assets/pfp.png

return {

  -- █░█ █
  -- █▄█ █

  -- Set desired theme and style.
  -- Default available options:
  --    > [mountain] fuji
  --    > [nord] dark light
  --    > [dcm] pulse
  theme_name  = "mountain",
  theme_style = "fuji",

  -- If Cozy's theme switcher should try to switch themes for other applications.
  -- See `theme/integration.lua` for details and setup examples.
  -- Disabled by default as it requires manual configuration.
  theme_switch_integration = false,

  -- Font style to use. Cozy will autogenerate every combination of weights and sizes.
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

  -- Set bar alignment.
  -- Options:
  --    > [hbar] top bottom
  --    > [vbar] left right
  --    > [pulsebar] top
  bar_align = "top",

  -- Set bar style. Default style is vertical.
  -- Options: hbar vbar pulsebar
  bar_style = "hbar",

  -- Show notifications for playerctl.
  playerctl_notifications = true,

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

  -- Configure the visibility and order of tabs.
  -- Options: setup main task ledger calendar goals settings
  tabs = { "main", "task", "ledger", "calendar" },

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
    "Anti-Python",
    "Average Chebyshev enjoyer",
    "Disciple of the peaceful atom",
    "In no rush",
  },

  -- List of quotes to display on the main tab.
  quotes = {
    { "Everything you want is on the other side of fear.",
      "Jack Canfield", },
    { "Nothing happens to anyone that they can't endure.",
      "Marcus Aurelius", },
  },

  -- Icon shown on bar and at bottom of dash sidebar.
  distro_icon = "",

  -- Graph IDs of daily habits to track.
  -- Used with Pixela: https://pixe.la/
  habits = { "coding", "ledger", "studying", "journal", "outside", "music", "reading", },

  ----------------------------
  --------- LEDGER -----------
  ----------------------------

  -- Ledger files to read from.
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
}
