return {
  -- available themes:
  -- nord_dark, dracula, tokyo_night, 
  -- gruvbox_dark, gruvbox_light,
  -- catppuccin_macchiato
  theme = "tokyo_night",
  display_name = "Display Name",
  goals = {
    "Update user_vars",
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
  titles = {
    "Mechromancer",
    "Open sourcerer",
    "Vim wizard",
    "CLI sorcerer",
  },
  habit = {
    -- { name,        graph_id,       frequency},
    { "Make bed",     "make-bed",     "daily" },
    { "Journal",      "journal",      "daily"},
    { "Touch grass",  "go-outside",   "daily"},
    { "Ledger",       "ledger",       "daily"},
    { "Coding",       "pomocode",     "daily"},
    { "Read",         "reading",      "daily"},
  },
}
