#!/usr/bin/env python3

# █▄░█ █░█ █ █▀▄▀█    █▀█ █▀▀ █░░ █▀█ ▄▀█ █▀▄ 
# █░▀█ ▀▄▀ █ █░▀░█    █▀▄ ██▄ █▄▄ █▄█ █▀█ █▄▀ 

# (c) 2017 Daniel Jankowski
# Modified by Alexis G.

# tldr:
# Every nvim instance has a socket located in /run/user/1000
# (it used to be in /tmp but I don't know why or when that changed)
# This script sets the theme, checks /run/user/1000 for nvim sockets,
# and then sends command to source theme file to every socket.
# This is very specifically tailored to MY custom nvim config.
# The method by which you reload your nvim theme may be different,
# but it should be easy to modify this script to suit your needs.

import os
import sys
from neovim import attach

def get_all_instances():
  instances = []
  directory_content = os.listdir('/run/user/1000')
  for dirent in directory_content:
    if dirent.startswith('nvim'):
      if '0' in dirent:
        instances.append('/run/user/1000/' + dirent)
  return instances

def reload(instance, cfg):
  # connect over the socket
  nvim = attach('socket', path=instance)

  # re-source theme
  nvim.command("source " + cfg)

def main():
  # search for neovim instances
  instances = get_all_instances()

  # get args
  cfg = sys.argv[1]

  # connect to instances and reload them
  for instance in instances:
    reload(instance, cfg)
  pass


if __name__ == '__main__':
  main()
