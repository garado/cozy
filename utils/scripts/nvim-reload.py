#!/usr/bin/env python3

# █▄░█ █░█ █ █▀▄▀█    █▀█ █▀▀ █░░ █▀█ ▄▀█ █▀▄ 
# █░▀█ ▀▄▀ █ █░▀░█    █▀▄ ██▄ █▄▄ █▄█ █▀█ █▄▀ 

# (c) 2017 Daniel Jankowski
# modified @garado

# tl; dr:
# Every nvim instance has a socket located in /run/user/1000
# (it used to be in /tmp but I don't know why or when that changed)
# This script sends a command to change the nvim theme to every socket.
# This is very specifically tailored to MY custom nvim config.
# The method by which you reload your nvim theme may be different,
# but it should be easy to modify this script to suit your needs.

import os
import sys
from pynvim import attach

def get_all_instances():
    instances = []
    directory_content = os.listdir('/run/user/1000')
    for dirent in directory_content:
        if dirent.startswith('nvim'):
            instances.append('/run/user/1000/' + dirent)
    return instances

def reload_theme(instance, cmd):
    try:
        nvim = attach('socket', path=instance)
    except Exception as e:
        return
    nvim.command(cmd)

def main():
    # search for neovim instances
  instances = get_all_instances()

  # get args
  cmd = sys.argv[1]

  # connect to instances and reload them
  for instance in instances:
      reload_theme(instance, cmd)

if __name__ == '__main__':
    main()
