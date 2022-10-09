
▀█▀ ▄▀█ █▀ █▄▀    █▀▄▀█ ▄▀█ █▄░█ ▄▀█ █▀▀ █▀▀ █▀█ 
░█░ █▀█ ▄█ █░█    █░▀░█ █▀█ █░▀█ █▀█ █▄█ ██▄ █▀▄ 

A frontend for Taskwarrior created with AwesomeWM.

# task_obj
This is the backbone of the task object.

It contains the following fields:
- task_obj.projects (rename to project_list later)
  - list of projects associated with the current tag
- task_obj.current_project
  - the currently selected project for the current tag
- task_obj.current_tag
  - the... current tag
- task_obj.current_task
  - this is the output for each task from `task export` command
  - contains fields like `due`, `id`, `start`, `description`, etc

# Core components
## Keygrabber
Defines keyboard shortcuts for the task manager.

## Project overview

## Parser

## Projects

## Prompt

## Stats

## Tags

