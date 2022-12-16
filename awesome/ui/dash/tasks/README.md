
▀█▀ ▄▀█ █▀ █▄▀    █▀▄▀█ ▄▀█ █▄░█ ▄▀█ █▀▀ █▀▀ █▀█ 
░█░ █▀█ ▄█ █░█    █░▀░█ █▀█ █░▀█ █▀█ █▄█ ██▄ █▀▄ 

A frontend for Taskwarrior created with AwesomeWM.
This documentation is mainly for myself.

# task_obj
This is the backbone of the task object.
It contains data that needs to be accessed by different modules and is
also responsible for carrying signals that modules need to communicate with
each other.

# Fields in task_obj
It contains the following fields:
- `task_obj.current_project`
  - the currently selected project for the current tag
- `task_obj.current_tag`
- `task_obj.current_task`
  - without!! pango markup
- `task_obj.current_id`
  - this is set within one of the custom navitem functions
- `task_obj.current_task_index`
  - the current task index within the overview panel
- `task_obj.projects`
  - list of projects associated with the current tag
- `task_obj.projects["project_name"].tasks`
  - table containing task data retrieved from the `task export` command
  - each task gets its own table which contains fields like `due`, `id`, `start`, `description`, etc
  - e.g. to get the description of the 1st task associated with the project "linux":
    - `task_obj.projects["linux"].tasks[1]["description"]`

# Diagrams
## Anatomy of the task manager
this was really not necessary, 
but i just got a new ascii art diagram plugin and i am very excited to use it :-)
```
 ┌───────────────────────────────────────────────────────────────────────────────────┐
 │┌──────────────────┐ ┌────────────────────────────────────────────────────────────┐│
 ││                  │ │┌──────────────────────────────────────────────────────────┐││
 ││       TAGS       │ ││                  TASKLIST HEADER                         │││
 ││                  │ ││                                                          │││
 │└──────────────────┘ │└──────────────────────────────────────────────────────────┘││
 │┌──────────────────┐ │┌──────────────────────────────────────────────────────────┐││
 ││                  │ ││                                                          │││
 ││                  │ ││                                                          │││
 ││                  │ ││                                                          │││
 ││     PROJECT      │ ││                                                          │││
 ││       LIST       │ ││                                                          │││
 ││                  │ ││                       TASKLIST                           │││
 ││                  │ ││                                                          │││
 ││                  │ ││                                                          │││
 │└──────────────────┘ ││                                                          │││
 │┌──────────────────┐ ││                                                          │││
 ││                  │ ││                                                          │││
 ││      STATS       │ ││                                                          │││
 ││                  │ ││                                                          │││
 ││                  │ │└──────────────────────────────────────────────────────────┘││
 │└──────────────────┘ └────────────────────────────────────────────────────────────┘│
 └───────────────────────────────────────────────────────────────────────────────────┘
```

## How project_list draws new projects
```
┌────────────────────────┐     ┌───────────────┐    ┌──────────────┐
│ receive signal telling │     │count projects │    │ draw project │
│ it to draw new project │────►│   in tag()    │───►│   list()     │
│         list           │     └───────────────┘    └──────────────┘
└────────────────────────┘     does exactly what           │
                               it sounds like lol          │ for every project,
                                                           │     do this
                                                           │
                                                           ▼
      ┌───────────────────────────────────────────────────────────────────────────────────────────────────────┐
      │ ┌───────────────────────────────────┐                            ┌──────────────────────────────────┐ │
      │ │     create_project_button()       │       emit                 │          project_list            │ │
      │ │                                   │  async_call_completed      │ ++counter for # calls completed. │ │
      │ │- async call to get total number   │      signal                │ add widget to a buffer.          │ │
      │ │  of tasks associated with project │─────────────────────────►  │ if all async calls are finished, │ │
      │ │  (completed + pending), used to   │ also send the widget       │ draw the buffer to the screen.   │ │
      │ │  calculate completion percentage  │    with signal             │                                  │ │
      │ └───────────────────────────────────┘                            └──────────────────────────────────┘ │
      └───────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
## After modifying tasklist (eg adding a new task, changing the due date, etc)
```
  ┌───────┐ project_              project_json_   ┌───────┐
  │prompt │ modified     ┌──────┐  parsed         │project│
  │handler│────────────► │parser│ ──────────────► │ list  │
  └───────┘              └──────┘                 └───────┘
user modifies a         fetch and parse          draw new project
     task                project json            list from json
                         from taskwarrior
```

## When a new task is selected
```
  ┌────────┐  task_selected    ┌────────┐
  │navitems│ ───────────────►  │overview│
  └────────┘                   └────────┘
  select_on()                update task_obj.current_task_index  
    called                       with index from nav_overview
```

## Reload signals

# How scrollbar works
The tasklist displays max_tasks_shown tasks at a time (default 21)
- overflow buffers
  - top and bottom
  - these hold excess tasks (eg if you have more than max_tasks_shown tasks)
- scroll down
  - append 1st visible task to overflow_top; remove it from tasklist ui
  - append 1st task from overflow_bottom to tasklist ui; remove it from overflow_bottom
- scroll up
  - prepend last visible task to overflow_bottom; remove from tasklist ui
  - append 1st task from overflow_bottom to tasklist ui; remove it from overflow_bottom
- jump top
  - loop over scroll_up
- jump end
