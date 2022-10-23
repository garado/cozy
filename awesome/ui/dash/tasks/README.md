
▀█▀ ▄▀█ █▀ █▄▀    █▀▄▀█ ▄▀█ █▄░█ ▄▀█ █▀▀ █▀▀ █▀█ 
░█░ █▀█ ▄█ █░█    █░▀░█ █▀█ █░▀█ █▀█ █▄█ ██▄ █▀▄ 

A frontend for Taskwarrior created with AwesomeWM.
This documentation is mainly for myself.

# task_obj
This is the backbone of the task object.

# Fields in task_obj
It contains the following fields:
- `task_obj.current_project`
  - the currently selected project for the current tag
- `task_obj.current_tag`
- `task_obj.current_task`
  - without!! pango markup
- `task_obj.current_id`
  - this is set within one of the custom navitem functions
- `task_obj.projects`
  - list of projects associated with the current tag
- `task_obj.projects["project_name"].tasks`
  - table containing task data retrieved from the `task export` command
  - each task gets its own table which contains fields like `due`, `id`, `start`, `description`, etc
  - e.g. to get the description of the 1st task associated with the project "linux":
    - `task_obj.projects["linux"].tasks[1]["description"]`

# Signals
- after modifying tasklist (eg adding a new task, changing the due date, etc)
  - **prompt**:           emit `tasks::project_modified`
  - **parser**:           connect `tasks::project_modified`; fetch and parse project json; emit `tasks::project_json_parsed`
  - **projectlist**:      connect `tasks::project_json_parsed`; draw new project list
  - **projectlist**:      emit `tasks::project_async_done`
  - **projectlist**:      emit `tasks::project_selected` when catching first project_async done signal
  - **projectoverview**:  connect `tasks::project_selected`; draw project overview
