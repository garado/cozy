# Theme guide
This is a reference for creating a custom theme for Cozy.

Partly based on NvChad Base46 specifications.

## Setting default colors
| name        | desc/guidelines     | usage                        | notes                        |
| ----------- | ------------------- | -------------                | --------------------         |
| bg_d0       | 6% darker bg        | unused                       |                              |
| bg          | base bg color       | main widget/wibar bg         |                              |
| bg_l0       | 6% lighter bg       | dash widget bg               |                              |
| bg_l1       | 10% lighter bg      |                              |                              |
| bg_l2       | 19% lighter bg      | buttons                      |                              |
| bg_l3       | 27% lighter bg      | album filter, wibar_occupied |                              |
| fg          | base fg color       | main text color              |                              |
| fg_sub      | darker fg color     | subtitles                    |                              |
| fg_alt      | lighter fg color    | alt text                     |                              |
| main_accent |                     |                              |                              |
| accents     |                     |                              | should contrast well with bg |

## Setting custom colors
Changing the colors above should be enough to change the colorscheme of all widgets, but if you want finer-grained control over everything, you can override almost every color for every UI element.

See `awesome/theme/theme.lua` for a list of all color variables and their respective defaults. To override them, set their values in your custom `colorscheme.lua`.


## Integrating with other applications
The theme switcher includes functionality for changing the themes for other applications so that your entire system can have an effortlessly consistent aesthetic. By default, it supports Kitty and NvChad.

Theme switch integration is disabled by default because everyone uses different applications. To enable it, uncomment this line in `awesome/theme/theme.lua`:

`require("theme/theme_switcher")()`

To integrate theme switching with the applications you want, you have to write your own theme switch function in `awesome/theme/theme_switcher.lua`. For this you must know how to change the application's theme through the command line.

Example theme switch function:

```
local function kitty()
  -- This should be set in <colorscheme>.lua
  local kitty_theme = theme.kitty

  -- The command to change the application's color scheme
  local cmd = "kitty +kitten themes --reload-in=all " .. kitty_theme
  awful.spawn(cmd)
end
```

Then call the function at the end of the file:

```
return function()
  if theme.kitty  then kitty()  end
  if theme.nvchad then nvchad() end
end
```
