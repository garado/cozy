#!/usr/bin/env python3
# dwm-theme-switcher
# (c) 2017 Daniel Jankowski

import os
import sys
from neovim import attach

def get_all_instances():
  instances = []
  
  # get the content of /tmp
  directory_content = os.listdir('/tmp')
  for directory in directory_content:
    # check if it contains directories starting with nvim
    if directory.startswith('nvim'):
      # check if the nvim directories contains a socket
      dc = os.listdir('/tmp/' + directory)
      if '0' in dc:
        instances.append('/tmp/' + directory + '/0') 
  return instances

def reload(instance, theme):
  # connect over the socker
  nvim = attach('socket', path=instance)

  # execute the reload command
  nvim.command("let g:nvchad_theme = '" + theme + "'")
  nvim.command("lua require('nvchad').reload_theme()")


def main():
  # search for neovim instances
  instances = get_all_instances()

  # get cmd line args
  theme = str(sys.argv[1])

  # connect to instances and reload them
  for instance in instances:
    reload(instance, theme)
  pass


if __name__ == '__main__':
  main()
