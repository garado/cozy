<h1 align="center">Cozy</h1>

<p align="center">
  <img title="" src="assets/showcase.png" width="900">
</p>

<p> Hi! This is <b>Cozy</b>, my AwesomeWM config that I've spent way too much time on. </p>

<h3> ⚠️ Warning </h3>

<p>This project is undergoing heavy refactoring and is best used as a code reference for now. It probably won't work out of the box on your machine. Support is also limited as I'm busy with school. </p>

<!-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ -->
<!-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ -->

<h2>Dashboard</h2>

<p>
  The dashboard is a collection of graphical interfaces for several command-line applications, including <a href="https://github.com/ledger/" target="_blank">ledger</a>, <a href="https://taskwarrior.org/" target="_blank">taskwarrior</a>, <a href="https://timewarrior.net" target="_blank">timewarrior</a>, and <a href="https://github.com/insanum/gcalcli" target="_blank">gcalcli</a>.
</p>

<p>
  The dashboard (as well as every other popup) is fully keyboard navigable with Vim-like keybinds using a custom navigation library.
</p>

<h4>Main tab</h4>
<p align="center">
  <img title="" src="./assets/dash_main.png" width="800">
</p>
<ul>
  <li>Habit-tracking with <a href="https://pixe.la">Pixela</a></li>
  <li>Github contributions widget <a href="https://github.com/streetturtle/awesome-wm-widgets/blob/master/github-contributions-widget/README.md">(streetturtle)</a></li>
  <li>View current Timewarrior time-tracking</li>
</ul>

<h4>Task management</h4>
<p align="center">
  <img title="" src="./assets/dash_task.png" width="800">
</p>
<ul>
  <li>Aesthetic and easy-to-use GUI for Taskwarrior</li>
  <li>Add, view, and edit tasks from dashboard</li>
  <li>Start and stop tasks for easy time-tracking</li>
</ul>

<details>
<summary>Task manager keybinds</summary>

| Keybind          | Action                 |
| -------          | ------                 |
| <kbd>a</kbd>     | Add task               |
| <kbd>s</kbd>     | Toggle start/stop task |
| <kbd>d</kbd>     | Mark task as done      |
| <kbd>x</kbd>     | Delete task            |
| <kbd>R</kbd>     | Reload tasks           |
| <kbd>/</kbd>     | Search                 |
| <kbd>m + d</kbd> | (modify) due date      |
| <kbd>m + p</kbd> | (modify) project name  |
| <kbd>m + t</kbd> | (modify) tag name      |
| <kbd>m + n</kbd> | (modify) task name     |

</details>

<h4>Agenda</h4>
<p align="center">
  <img title="" src="./assets/gif/agenda.gif" width="800">
</p>
<ul>
  <li>Add, view, and edit Google Calendar events</li>
  <li>Open meeting links directly from dashboard</li>
  <li>View <a href="https://github.com/streetturtle/awesome-wm-widgets/blob/master/weather-widget/weather.lua" target="_blank">forecast</a>, goals, and deadlines for this week</li>
  <li>Calendar with heatmap showing which days are busiest</li>
</ul>

<details>
<summary>Agenda keybinds</summary>

| Event list       | Action                 |
| -------          | ------                 |
| <kbd>R</kbd>     | Refresh/resync         |
| <kbd>a</kbd>     | Add event              |
| <kbd>x</kbd>     | Delete event           |
| <kbd>o</kbd>     | Open link              |
| <kbd>m + t</kbd> | (modify) event title   |
| <kbd>m + l</kbd> | (modify) location      |
| <kbd>m + w</kbd> | (modify) when          |
| <kbd>m + d</kbd> | (modify) duration      |


| Calendar     | Action               |
| -------      | ------               |
| <kbd>H</kbd> | Previous month       |
| <kbd>L</kbd> | Next month           |
| <kbd>t</kbd> | Jump to this month   |

| Infobox (bottom left) | Action         |
| -------               | ------         |
| <kbd>h, l</kbd>       | Cycle  widgets |

</details>

<h4>Ledger</h4>
<p align="center">
  <img title="" src="./assets/dash_ledger.png" width="800">
</p>
<ul>
  <li>View budget, account balances, and spending history</li>
  <li>Quickly access ledger files to add or update ledger entries</li>
</ul>

<h4>Journal</h4>
<p align="center">
  <img title="" src="./assets/gif/journal.gif" width="800">
</p>
<ul>
  <li>View past journal entries and quickly create new ones (idk, I like to reread them a lot)</li>
</ul>

<!-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░    █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█ --> 
<!-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄    █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄ --> 

<h2>Control center</h2>

<p align="center">
  <img title="" src="./assets/control.png" width="400">
</p>

<ul>
  <li>Picom animation settings</li>
  <li>Handy set of quick actions</li>
</ul>

<!-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ -->
<!-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ -->

<h2>Theme switcher</h2>

<p align="center">
  <img title="" src="./assets/themeswitch.gif">
</p>

<p>
  Changes AwesomeWM theme and themes for other applications (Rofi, Zathura, Nvim, Kitty). Easily extendable to other applications as well.
</p>

<details><summary>Themes preview</summary>
  <p align="center">
    <img title="nord" width="550" src="./assets/themes/nord.png">
  </p>
  <p align="center">
    <img title="kanagawa" width="550" src="./assets/themes/kanagawa.png">
  </p>
  <p align="center">
    <img title="mountain" width="550" src="./assets/themes/mountain.png">
  </p>
  <p align="center">
    <img title="nostalgia" width="550" src="./assets/themes/nostalgia.png">
  </p>
  <p align="center">
    <img title="gruvbox" width="550" src="./assets/themes/gruvbox.png">
  </p>
</details>

<!-- █▀▀ █▀█ █▀█ ▀█▀ █▄░█ █▀█ ▀█▀ █▀▀ █▀ --> 
<!-- █▀░ █▄█ █▄█ ░█░ █░▀█ █▄█ ░█░ ██▄ ▄█ --> 

<h3>Other stuff</h3>
<b>Why is it called 'cozy'?</b> 
I've spent a lot of time tweaking this setup to be just the way I like it, so now this setup feels very personal, comfortable, and cozy.  :-)

<h3>Credits</h3>
<ul>
<li><a href="https://github.com/rxyhn/yoru" target="_blank">rxyhn</a> for code reference
<li><a href="https://github.com/adi1090x/rofi" target="_blank">adi1090x</a> for rofi theme
<li><a href="https://github.com/siddhanthrathod/bspwm" target="_blank">siddhanthrathod</a> for picom configuration
<li><a href="https://github.com/nickclyde/rofi-bluetooth" target="_blank">nick clyde</a> for rofi-bluetooth
</ul>
