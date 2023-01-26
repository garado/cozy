
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local gfs = require("gears.filesystem")

-- I gotta find a better way to find this
local CWD = gfs.get_configuration_dir() .. (...):match("(.-)[^%.]+$"):sub(1, -2)

return {

  -- List of dashboard tabs to hide.
  -- Possible values:
  -- "main", "tasks", "agenda", "cash", "time", "journal"
  exclude_dash_tabs = {

  },

  --  █▀▄▀█ ▄▀█ █ █▄░█
  --  █░▀░█ █▀█ █ █░▀█

  -- Icon to show at the bottom of the tab bar.
  -- https://www.nerdfonts.com/cheat-sheet
  distro_icon = "",

  -- The name to display on the main tab.
  display_name = "Display Name",

  -- Fun stuff to show beneath display name.
  titles = {
    "Mechromancer",
    "Open sourcerer",
    "Vim wizard",
    "CLI sorcerer",
    "Uses Arch, btw",
    "Linux enthusiast",
  },

  -- The goals widget looks best if the strings are short (so they don't 
  -- wrap) and if there are a maximum of 5-6 goals set here.
  goals = {
    "Goal 1",
    "Goal 2",
    "Goal 3",
  },

  -- For contributions widget.
  github = {
    username = "garado",
  },

  pixela = {
    -- Pixela username and user token.
    -- You can set these here if they aren't already set elsewhere,
    -- i.e. as environment variables
    -- user  = "",
    -- token = "",

    -- Which habits to show in the habit tracker.
    habits = {
      -- graph id         display name      frequency
      ["graph-id"]    = { "Habit name",     "daily" },
    },
  },


  -- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
  -- ░█░ █▀█ ▄█ █░█ ▄█ 

  -- The Taskwarrior tag/project to show on tab startup.
  tasks = {
    default_tag     = "",
    default_project = "",
  },


  -- ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
  -- █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

  agenda = {
    -- Get a free API key from OpenWeather: https://openweathermap.org/
    weather_api_key = "",

    -- Coordinates of location to fetch weather for .
    weather_coordinates = { 36.98, -122.05 },

    -- Path to the text file
    weekly_goals_path = {

    },
  },

  -- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
  -- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

  ledger = {
    -- File to read transactions from.
    ledger_file = CWD .. "/samplefiles/sample-ledger.ledger",

    -- File to read budget data from.
    budget_file = CWD .. "/samplefiles/sample-budget.ledger",

    -- List of files to open when pressing 'Open ledger'.
    ledger_open = {
      CWD .. "/samplefiles/sample-budget.ledger",
      CWD .. "/samplefiles/sample-ledger.ledger",
    },
  },


  -- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
  -- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

  journal = {
    -- This is obviously not secure as it's in plaintext.
    -- It's moreso to prevent people who are looking at your screen from
    -- seeing your journal entries if you accidentally open the journal
    -- tab.
    password = "password",
  },

}
