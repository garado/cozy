
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

local gfs = require("gears.filesystem")
local CWD = gfs.get_configuration_dir() .. "cozyconf/"

return {

  -- Certain widgets can send Pushover notifications.
  -- Put your user key and application API token here.
  -- https://pushover.net/settings
  pushover = {
    user_key = "",
    api_token = "",
  },

  -- █▀▄▀█ ▄▀█ █ █▄░█    ▀█▀ ▄▀█ █▄▄ 
  -- █░▀░█ █▀█ █ █░▀█    ░█░ █▀█ █▄█ 

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

  -- Icon to show at the bottom of the tab bar.
  distro_icon = "",

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

  -- For bus tracking widget. You probably won't need this unless you
  -- live in my city (Santa Cruz).
  bus = {},

  -- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
  -- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

  tasks = {
    -- The Taskwarrior tag/project to show on tab startup.
    default_tag     = "",
    default_project = "",

    -- Tags to exclude from display.
    exclude_tags = { },
  },


  -- ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
  -- █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

  agenda = {
    -- Get a free API key from OpenWeather: https://openweathermap.org/
    weather_api_key = "",

    -- The location to fetch weather for .
    weather_coords = { 36.98, -122.05 },

    -- If false, weekview will show the current week Sunday-Saturday
    -- If true, weekview will show today + 6 days
    weekview_start_from_today = false,

    -- Which day counts as the start of the week.
    -- Possible values: any day of the week, fully spelled out, first letter
    -- capitalized.
    weekview_week_start = "Sunday",
  },


  -- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
  -- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

  ledger = {
    -- File to read transactions from.
    ledger_file = CWD .. "samplefiles/sample-ledger.ledger",

    -- File to read budget data from.
    budget_file = CWD .. "samplefiles/sample-budget.ledger",

    -- List of files to open when pressing 'Open ledger'.
    ledger_open = {
      CWD .. "samplefiles/sample-budget.ledger",
      CWD .. "samplefiles/sample-ledger.ledger",
    },
  },


  -- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
  -- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

  time = {

    -- If enabled, you can view an estimate of your earnings from hourly-pay
    -- jobs by tracking hours with Timewarrior under a specific tag.

    -- Whether to enable earnings overview.
    show_earnings = true,

    -- Specify display name, work tag to search for,
    -- and the hourly rate for each job.
    jobs = {
      {
        name = "Nath",
        tag  = "Work:Nath",
        rate = 23.92,
      },
      {
        name = "Siero",
        tag  = "Work:Siero",
        rate = 17.78,
      },
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
