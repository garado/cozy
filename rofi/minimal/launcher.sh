#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

dir="$HOME/.config/rofi"
theme="$HOME/.config/rofi/config.rasi"

rofi -no-lazy-grab -show run -modi run,window -theme "$theme"
