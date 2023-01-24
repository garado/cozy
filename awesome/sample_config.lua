
-- █▀ ▄▀█ █▀▄▀█ █▀█ █░░ █▀▀    █▀▀ █▀█ █▄░█ █▀▀ █ █▀▀ 
-- ▄█ █▀█ █░▀░█ █▀▀ █▄▄ ██▄    █▄▄ █▄█ █░▀█ █▀░ █ █▄█ 

-- Copy this to config.lua!

return {
  lock = {
    pin = "1356", -- must be a string
    enable_lockscreen_on_start = false,
  },
  theme_name  = "nord",
  theme_style = "dark",
  theme_switch_integration = false,
  -- Define displayed_themes if you want to only show specific themes
  -- in the theme switcher
  -- displayed_themes = {
  --   ["mountain"] = true,
  --   ["kanagawa"] = true,
  --   ["nord"] = true,
  -- },
  ---
  display_name = "Display Name",
  goals = {
    "Update config",
    "Post to r/unixporn",
    "Be kind to myself",
  },
  ledger = {
    ledger_file = "~/.config/awesome/misc/sample.ledger",
    budget_file = "~/.config/awesome/misc/budget.ledger",
  },
  pomo = {
    topics = {
      "School",
      "Personal",
      "Hobby",
      "Rice",
    },
  },
  pixela = {
    user  = "",
    token = "",
  },
  titles = {
    "Mechromancer",
    "Open sourcerer",
    "Vim wizard",
    "CLI sorcerer",
    "Uses Arch, btw",
  },
  habit = {
    -- graph id         display name    frequency
    ["make-bed"]    = { "Make bed",     "daily" },
    ["journal"]     = { "Journal",      "daily"},
    ["go-outside"]  = { "Touch grass",  "daily"},
    ["ledger"]      = { "Ledger",       "daily"},
    ["pomocode"]    = { "Coding",       "daily"},
    ["reading"]     = { "Read",         "daily"},
  },
  git = {
    {
      name = "",
      repo = "",
      msg = "",
    },
  },
  journal = {
    -- This is obviously NOT meant to be bulletproof
    -- This is just to prevent for example people sitting behind you from seeing
    -- your deep dark jrnl secrets.
    password = "password"
  },
  bookmarks = {
    path = "$HOME/Documents/bookmarks.json",
  },
}
