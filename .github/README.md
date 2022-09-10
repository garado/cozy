<h1 align="center">cozy</h1>

<p align="center">
  <img title="" src="assets/animation_demo.gif">
</p>

<p>
Hi! This is <b>cozy</b>, my <a href="https://awesomewm.org" target="_blank">AwesomeWM</a> config. Thanks for checking it out!
</p>

<p>
  The primary goals of this setup are to create an environment that:
</p>

<ol>
<li>can be used easily on both my laptop and my touchscreen tablet</li>
<li>integrates all the cli tools I use to manage my life into a nice dashboard</li>
<li>looks awesome!</li>
</ol>

<h2>🚀 Features</h2>
<h4>Dashboard</h4>
<p align="center">
  <img title="" src="assets/dash_main.png" alt="" width="800">
</p>

<ul>
<li>Fancy music player (thank you <a href="https://github.com/rxyhn/yoru" target="_blank">rxhyn</a>)</li>
<li>Calendar (with Google Calendar) </li>
<li>To do list (with <a href="https://taskwarrior.org/" target="_blank">Taskwarrior</a>)</li>
<li>Time tracking (with <a href="https://timewarrior.net" target="_blank">Timewarrior</a>)</li>
<li>Interactive habit tracker (with <a href="https://pixe.la" target="_blank">Pixela</a>)</li>
<li>Fancy finances (with <a href="https://github.com/ledger/" target="_blank">Ledger</a>)</li>
<li>(WIP) Different tabs to show even more information!</li>
</ul>


<h4>Theme switcher</h4>

<p align="center">
  <img title="" src="assets/theme_switcher.gif" alt="" width="800">
</p>

The theme switcher can set the theme for your entire system - not just Awesome. By default, it switches the Kitty, NvChad, and GTK themes, but it is easily extensible to whichever applications you use.

Built-in themes:

| Theme name | Styles       |
|------------|--------------|
| nord       | dark, light  |
| dracula    | dark         |
| tokyonight | dark         |
| gruvbox    | dark, light  |
| catpuccin  | mocha, latte |

<ul>
  <li>
    <details><summary><b>nord</b></summary>
      <p align="center">
        <img title="" width="800" src="assets/themes/nord_dark.png">
      </p>
      <p align="center">
        <img title="" width="800" src="assets/themes/nord_light.png">
      </p>
    </details>
  </li>
  <li>
    <details><summary><b>dracula</b></summary>
      <p align="center">
        <img title="" width="800" src="assets/themes/dracula.png">
      </p>
    </details>
  </li>
  <li>
    <details><summary><b>catpuccin</b></summary>
      <p align="center">
        <img title="" width="800" src="assets/themes/catppuccin_macchiato.png">
      </p>
    </details>
  </li>
  <li>
    <details><summary><b>tokyo_night</b></summary>
      <p align="center">
        <img title="" width="800" src="assets/themes/tokyo_night.png">
      </p>
    </details>
  </li>
  <li>
    <details><summary><b>gruvbox</b></summary>
      <p align="center">
        <img title="" width="800" src="assets/themes/gruvbox_dark.png">
      </p>
      <p align="center">
        <img title="" width="800" src="assets/themes/gruvbox_light.png">
      </p>
    </details>
  </li>
</ul>

<h2>🔧 Install and configure</h2>
<b>NOTE: This setup is incomplete and under constant development.</b> If you want to use it, be prepared to update frequently.


<details><summary><b>Install</b></summary>

Install dependencies (Arch/Arch-based)

<pre><code>yay -S awesome-git gcalcli nerd-fonts-roboto-mono ttf-roboto picom-pijulius-git
pacman -S playerctl rofi scrot pamixer brightnessctl upower task timew ledger mpg123
</code></pre>

Clone repository

<code>git clone --recurse-submodules https://github.com/garado/cozy.git</code>

(Optional) Make a backup of your old configs

<pre><code>cp -r ~/.config/awesome/ ~/.config/awesome.${USER}/
cp -r ~/.config/rofi/ ~/.config/rofi.${USER}/
cp ~/.config/picom.conf ~/.config/picom.${USER}.conf</code></pre>

Copy configs

<pre><code>cd cozy && cp -r awesome/ rofi/ picom.conf ~/.config/</pre></code>

Copy sample_user_variables.lua to user_variables.lua.
Edit it how you like.

<pre><code>cp sample_user_variables.lua user_variables.lua</pre></code>

Copy <code>misc/on-add-update-dash</code> and <code>misc/on-modify-update-dash</code> to your Taskwarrior hooks folder (default location is <code>~/.task/hooks</code>). This updates the task widget whenever Taskwarrior tasks are added/modified.

<code>cp misc/on-add-update-dash misc/on-modify-update-dash ~/.task/hooks/</code>

</details>


<details><summary><b>Configure</b></summary>

Most configuration happens in <code>awesome/configuration/*</code> and <code>awesome/user_variables.lua</code>.

Make sure you update <code>configuration/apps.lua</code> with your default terminal/file manager/browser applications.

<b>Themes</b>

Change the theme and style in `user_variables.lua`.


<b>Google Calendar events</b>

- Follow instructions to [set up gcalcli](https://github.com/insanum/gcalcli#login-information)
- The calendar widget checks `~/.cache/awesome/calendar/agenda` for data (in tsv format). It will automatically fetch data if it detects that there is no data in the file.
- To keep your widget updated, periodically update the cache by putting `gcalcli agenda --tsv > ~/.cache/awesome/calendar/agenda` in a cron job.

<b>Pixela habit tracker</b>

- <a href="https://pixe.la/" target="_blank">Read these instructions</a> to create a Pixela account and create your habits
- Install <a href="https://github.com/a-know/pi" target="_blank">pi</a> (command line Pixela tool)
  - The install instructions on pi's Github page don't work, follow this:
  - `go install github.com/a-know/pi/cmd/pi@latest`
  - Put `pi` (located in `$HOME/go/bin`) in your path
  - Set the `PIXELA_USER_NAME` and `PIXELA_USER_TOKEN` environment variables
    - <b>Note:</b>Some login managers like LightDM don't start Awesome in an interactive shell, which means Awesome won't source your .zshrc/.bashrc/.whateverrc and thus won't recognize your Pixela env vars or path if you set them there. As a workaround you can either put your Pixela env vars and `pi` path in a place that's always sourced like `.zshenv`, or you can put your user name and user token directly in `user_variables.lua`.
- Update `user_variables.lua` with the habits you want to display
- The `utils/dash/habits/cache_habits` script caches data from Pixela. Read the script documentation. Run it periodically with a cron job to keep your widget updated. 


<b>Finances tracker</b>

- Update <code>user_variables.lua</code> with the ledger file to read from 

</details>


<h2>🗒️ In progress/planned features</h2>
<details><summary><b>Dashboard tabs</b></summary>

<ul>
  <li>Finances</li>
    <ul>
      <li>Budget tracking</li>
      <li>Yearly account balance trends</li>
    </ul>
  <li>Habits/goals</li>
  <ul>
    <li>Goals tracker</li> 
    <li>Habit tracker</li>
  </ul>
  <li>Tasks/calendar</li>
  <ul>
    <li>Fancier task displays</li>
    <li>Calendar</li>
  </ul>
</ul>

</details>

<details><summary><b>Control center</b></summary>

<ul>
  <li>Quick actions</li>
</ul>

</details>

<details><summary><b>Bar</b></summary>

<ul>
  <li>Variable bar orientation!</li>
  <li>Systray</li>
  <li>Better app launcher</li>
</ul>

</details>

<details><summary><b>Other</b></summary>

<ul>
  <li>Theme switcher</li>
  <li>Custom rofi launcher</li>
  <li>Add icons</li>
</ul>

</details>

<h3>Other stuff</h3>
<b>Why is it called 'cozy'?</b> 

I've spent a lot of time tweaking this setup to be just the way I like it, so now this setup feels very personal, comfortable, and <b>cozy</b>.  :-)

<h3>Credits</h3>
<ul>
<li><a href="https://github.com/rxyhn/yoru" target="_blank">rxyhn</a> for code reference
<li><a href="https://github.com/adi1090x/rofi" target="_blank">adi1090x</a> for rofi theme
<li><a href="https://github.com/siddhanthrathod/bspwm" target="_blank">siddhanthrathod</a> for picom configuration
<li><a href="https://github.com/nickclyde/rofi-bluetooth" target="_blank">nick clyde</a> for rofi-bluetooth
</ul>
