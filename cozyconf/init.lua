
-- █▀▀ █▀█ ▀█ █▄█ █▀▀ █▀█ █▄░█ █▀▀ 
-- █▄▄ █▄█ █▄ ░█░ █▄▄ █▄█ █░▀█ █▀░ 

-- Cozy configuration options.

return {

  -- █░█ █
  -- █▄█ █

  -- Set desired theme and style.
  theme_name  = "nord",
  theme_style = "dark",

  -- If Cozy's theme switcher should try to switch themes for other applications.
  -- See `theme/integration.lua` for more details.
  theme_switch_integration = true,

  -- Font style to use.
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
      xxs = 9,
      xs  = 11,
      s   = 13,
      m   = 16,
      l   = 22,
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


  -- █▀▄▀█ █ █▀ █▀▀ 
  -- █░▀░█ █ ▄█ █▄▄ 

  -- GMT offset.
  timezone = -7,


  -- █▀▄ ▄▀█ █▀ █░█ 
  -- █▄▀ █▀█ ▄█ █▀█ 

  ---------------------------
  -------- MAIN TAB ---------
  ---------------------------

  -- The name to display on the main tab.
  name = "Alexis",

  -- List of titles to display beneath profile picture.
  titles = {
    "Vim enthusiast",
    "Mechromancer",
  },

  -- Icon shown at top of vbar and at bottom of dash sidebar.
  distro_icon = "",

  -- Selectable Timewarrior sessions.
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
