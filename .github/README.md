<h1 align="center">cozy</h1>

<p align="center">
  <img title="" src="assets/animation_demo.gif">
</p>

Hi! This is **cozy**, my [AwesomeWM](https://awesomewm.org/) config. Thanks for checking it out!

The primary goals of this setup are to create an environment that:

1. can be used easily on both my laptop and my touchscreen tablet
2. integrates all the cli tools I use to manage my life into a nice dashboard
3. looks awesome!

This is a port of my old Eww config. I've decided to keep maintaining the Eww config [here](https://github.com/garado/cozy/tree/eww) because I might leave Awesome one day. (Eww version is heavily wip and won't be updated as often)


<h2>🚀 Dashboard</h2>

<img title="" src="assets/dash_main.png" alt="" width="800">

**Features**

- Fancy music player (thank you [rxhyn](https://github.com/rxyhn/yoru))
- Calendar (with Google Calendar) 
- To do list (with [Taskwarrior](https://taskwarrior.org/))
- Time tracking (with [Timewarrior](https://timewarrior.net/))
  - Use the pomodoro widget for working in intervals
  - Or the focused time widget, for just starting/stopping time tracking - no intervals
- Interactive habit tracker (with [Pixela](https://pixe.la/))
- Fancy finances (with [Ledger](https://github.com/ledger/))
  - Monthly spending tracker
  - Current account balances
- (WIP) Different tabs to show even more information!



<h2>🔧 Install and configure</h2>
<b>NOTE: This setup is incomplete, somewhat buggy, and under constant development.</b> Because of that, I don't recommend daily driving it quite yet.


<details><summary><b>Install (Arch/Arch-based)</b></summary>

Install dependencies

- `yay -S awesome-git gcalcli nerd-fonts-roboto-mono ttf-roboto picom-pijulius-git`
- `pacman -S playerctl rofi scrot pamixer brightnessctl upower task timew ledger mpg123`

Clone repository

- `git clone --recurse-submodules https://github.com/garado/cozy.git`

(Optional) Make a backup of your old configs

- `cp -r ~/.config/awesome/ ~/.config/awesome.${USER}/`
- `cp -r ~/.config/rofi/ ~/.config/rofi.${USER}/`
- `cp ~/.config/picom.conf ~/.config/picom.${USER}.conf`

Copy configs

- `cd cozy && cp -r awesome/ rofi/ picom.conf ~/.config/`

Copy `misc/on-add-update-dash` and `misc/on-modify-update-dash` to your Taskwarrior hooks folder (default location is `~/.task/hooks`). This updates the task widget whenever Taskwarrior tasks are added/modified.

- `cp misc/on-add-update-dash misc/on-modify-update-dash ~/.task/hooks/`

Other theme stuff

| Name          | Source                                                               |
| ------------- | -------------------------------------------------------------------- |
| Cursors       | [Nordzy cursors](https://github.com/alvatip/nordzy-cursors)          |
| GTK theme     | [Nordic](https://github.com/EliverLara/Nordic)                       |
| Firefox theme | [Nordic](https://github.com/eliverlara/firefox-nordic-theme)         |
| Icon theme    | [Papirus-Nord](https://github.com/Adapta-Projects/Papirus-Nord)      |
| Vim theme     | [nord-vim](https://github.com/arcticicestudio/nord-vim)              |

</details>


<details><summary><b>Configure</b></summary>

Most configuration happens in `awesome/configuration/*` and `awesome/user_variables.lua`.

Make sure you update `configuration/apps.lua` with your default terminal/file manager/browser applications.

**Google Calendar events**

- Follow instructions to [set up gcalcli](https://github.com/insanum/gcalcli#login-information)
- The calendar widget checks `~/.cache/awesome/calendar/agenda` for data (in tsv format). It will automatically fetch data if it detects that there is no data in the file.
- To keep your widget updated, periodically update the cache by putting `gcalcli agenda --tsv > ~/.cache/awesome/calendar/agenda` in a cron job.

**Pixela habit tracker**

- [Read these instructions](https://pixe.la/) to create a Pixela account and create your habits
- Install [pi](https://github.com/a-know/pi) (command line Pixela tool)
  - The install instructions on pi's Github page don't work, follow this:
  - `go install github.com/a-know/pi/cmd/pi@latest`
  - Put `pi` (located in `$HOME/go/bin`) in your path
- Set the `PIXELA_USER_NAME` and `PIXELA_USER_TOKEN` environment variables
- Update `user_variables.lua` with the habits you want to display
- The `utils/dash/habits/cache_habits` script caches data from Pixela. Read the script documentation. Run it periodically with a cron job to keep your widget updated. 


**Finances tracker**

- Update `user_variables.lua` with the ledger file to read from 

</details>


<h2>🗒️ In progress/planned features</h2>
<details><summary><b>Dashboard tabs</b></summary>

- Main
  - [ ] different time tracking widget
- Finances
  - [o] List recent transactions
    - [X] base implementation
    - [ ] update ui
  - [ ] Budget tracking 
  - [ ] Yearly account balance trends 
- Habits/goals
  - [ ] Goals tracker
  - [ ] Habit tracker
- Tasks/calendar
  - [ ] Fancier task displays
    - [ ] Support subtasks + progress bar
  - [ ] Calendar

</details>

<details><summary><b>Control center</b></summary>

- [ ] Quick actions
- [ ] Power menu
- [ ] Volume/brightness control

</details>

<details><summary><b>Bar</b></summary>

- [ ] Volume/brightness control
- [ ] Variable bar orientation!
- [ ] Systray
- [ ] Better app launcher

</details>

<details><summary><b>Other</b></summary>

- **Other**
  - [ ] Theme switcher
  - [ ] Custom rofi launcher
- **Notifications**
  - [ ] Add icons

</details>

## Other stuff
<b>Why is it called 'cozy'?</b> 

I've spent a lot of time tweaking this setup to be just the way I like it, so now this setup feels very personal, comfortable, and <b>cozy</b>.  :-)

## Credits

- [rxhyn](https://github.com/rxyhn/yoru) for code reference
- [adi1090x]() for rofi theme
- [siddhanthrathod](https://github.com/siddhanthrathod/bspwm) for picom configuration
- [nick clyde](https://github.com/nickclyde/rofi-bluetooth) for rofi-bluetooth

