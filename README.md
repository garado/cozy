# awesome
<img src=".github/assets/showcase.png" width="1200">

Hi! This is my [AwesomeWM](https://awesomewm.org/) config. Thanks for checking it out!

The primary goal of this setup is to create an environment that:
  1. can be used easily on both my laptop and my touchscreen tablet
  2. integrates all the cli tools I use to manage my life into a nice dashboard
  3. looks awesome!

**NOTE: This setup is incomplete and under constant development.** Because of that, I don't recommend daily driving it quite yet unless you're ok with frequent potentially breaking changes.

# Installation (Arch)
(Install instructions still need to be tested. And again, I don't recommend installing it right now, but if you want to, then go crazy)

## Install dependencies
- `cd ~/.config/ && git clone --recurse-submodules https://github.com/garado/awesome_dotfiles.git awesome`
- `yay -S awesome-git gcalcli`
- `pacman -S playerctl upower nerd-fonts-roboto-mono task timew ledger`

## Configuration
**Google Calendar events**
- Follow instructions to [set up gcalcli](https://github.com/insanum/gcalcli#login-information)

**Pixela habit tracker**
- [Read these instructions](https://pixe.la/) to create a Pixela account and create your habits
- Install [pi](https://github.com/a-know/pi)
- Set the `PIXELA_USER_NAME` and `PIXELA_USER_TOKEN` environment variables
- Update `user_variables.lua` with the habits you want to display


**Finances tracker**
- Update `user_variables.lua` with the ledger file to read from 


# Dashboard
<img src=".github/assets/dash_main.png" width="800">

**Features**
- Fancy music player (thank you, [rxhyn](https://github.com/rxyhn/yoru))
- Events widget (with Google Calendar) 
- Tasks widget (with [Taskwarrior](https://taskwarrior.org/))
- Pomodoro timer (with [Timewarrior](https://timewarrior.net/))
- Habit tracker (with [Pixela](https://pixe.la/))
- Fancy finances (with [Ledger](https://github.com/ledger/))
  - Monthly spending tracker
  - Current account balances

## Dashboard tabs
I couldn't fit enough information onto the main dashboard page, so I'm adding tabs!

**Dashboard tab progress**
- Finances
  - [X] Recent transactions
  - [X] Monthly spending
  - [ ] Budget tracking 
  - [ ] Arc chart animations :)
  - [ ] Yearly account balance trends 
  - [ ] Redesign UI
- Habits/goals
  - [ ] Goals tracker
  - [X] Habit tracker
- Tasks/calendar
  - [ ] Fancier task displays
    - [ ] Support subtasks + progress bar
  - [ ] Calendar

# In progress
- **Control center**
  - [ ] Quick actions
  - [ ] Power menu
  - [ ] Volume/brightness control
- **Bar**
  - [X] Volume/brightness control
  - [ ] Variable bar orientation 
  - [ ] Systray
  - [ ] Better app launcher

# Credits
- [rxhyn](https://github.com/rxyhn/yoru) for code reference 
